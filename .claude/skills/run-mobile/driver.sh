#!/usr/bin/env bash
# Driver for running/driving the EduQuest Flutter app on an iOS Simulator.
# Verified on macOS (Xcode 16, iOS 26.5 runtime) against a real device UDID.
#
# Usage:
#   driver.sh build <device-udid>            # flutter pub get + first build/launch
#   driver.sh launch <device-udid>            # (re)launch after code changes
#   driver.sh screenshot <device-udid> <out.png>
#   driver.sh tap <device-udid> <orig-x> <orig-y>   # tap using ORIGINAL screenshot pixel coords
#   driver.sh backend-check                   # sanity-check which API port is serving current code
#
# "orig-x/orig-y" are pixel coordinates measured directly on a screenshot
# taken via `screenshot` (i.e. in the screenshot's native resolution, e.g.
# 1320x2868 for iPhone 17 Pro Max) - NOT the coordinates of some other
# scaled preview.

set -euo pipefail
cd "$(dirname "$0")/../../.."   # -> apps/mobile

APP_DIR="$PWD"
BUNDLE_ID="com.eduquest.mobile"

log() { echo "[driver] $*" >&2; }

cmd_build() {
  local udid="$1"
  flutter pub get
  flutter run -d "$udid"
}

cmd_launch() {
  local udid="$1"
  pkill -f "flutter run -d $udid" 2>/dev/null || true
  sleep 1
  local logfile="/tmp/eduquest_mobile_run.log"
  ( cd "$APP_DIR" && nohup flutter run -d "$udid" > "$logfile" 2>&1 & )
  log "launching, tailing $logfile for readiness..."
  for _ in $(seq 1 40); do
    grep -q "Dart VM Service" "$logfile" 2>/dev/null && { log "ready"; return 0; }
    grep -q "Error launching application\|BUILD FAILED" "$logfile" 2>/dev/null && {
      log "FAILED - see $logfile"; tail -30 "$logfile" >&2; return 1;
    }
    sleep 3
  done
  log "timed out waiting for launch - see $logfile"; return 1
}

cmd_screenshot() {
  local udid="$1" out="$2"
  xcrun simctl io "$udid" screenshot "$out"
}

# Tap-coordinate mapping: xcrun simctl has NO tap-injection command, so we
# click the Simulator.app window itself via System Events (osascript), which
# forwards the click as a touch event to the guest OS. This requires the
# calling process to have macOS Accessibility permission (System Settings >
# Privacy & Security > Accessibility) - see Gotchas in SKILL.md.
#
# The Simulator window reports its bounds in POINTS (via `get {position,
# size} of window 1`), but screenshots are taken at native device PIXEL
# resolution. The mapping (derived empirically, see SKILL.md):
#   scale    = window_height_pt / screenshot_height_px
#   offset_x = (window_width_pt - screenshot_width_px * scale) / 2
#   click_x  = window_x + offset_x + orig_x * scale
#   click_y  = window_y + orig_y * scale
# (No title bar offset needed - the Simulator window has no separate title
# bar; the traffic-light buttons float over the content area.)
cmd_tap() {
  local udid="$1" orig_x="$2" orig_y="$3"
  osascript -e 'tell application "Simulator" to activate'
  sleep 0.4

  local shot="/tmp/eduquest_mobile_tapcalib.png"
  xcrun simctl io "$udid" screenshot "$shot" >/dev/null
  local shot_w shot_h
  shot_w=$(sips -g pixelWidth "$shot" | awk '/pixelWidth/{print $2}')
  shot_h=$(sips -g pixelHeight "$shot" | awk '/pixelHeight/{print $2}')

  local win
  win=$(osascript -e 'tell application "System Events" to tell process "Simulator" to get {position, size} of window 1')
  # win looks like: "99, 41, 483, 1031" -> winX, winY, winW, winH
  IFS=', ' read -r win_x win_y win_w win_h <<< "$win"

  local click
  click=$(python3 - "$win_x" "$win_y" "$win_w" "$win_h" "$shot_w" "$shot_h" "$orig_x" "$orig_y" <<'PY'
import sys
win_x, win_y, win_w, win_h, shot_w, shot_h, ox, oy = map(float, sys.argv[1:9])
scale = win_h / shot_h
offset_x = (win_w - shot_w * scale) / 2
click_x = win_x + offset_x + ox * scale
click_y = win_y + oy * scale
print(f"{click_x:.0f} {click_y:.0f}")
PY
)
  local cx cy
  read -r cx cy <<< "$click"
  log "tapping window-space ($cx, $cy) for screenshot-space ($orig_x, $orig_y)"

  # Accessibility permission checks are flaky for a spawned/backgrounded
  # process - retry a couple of times before giving up (see Gotchas).
  local tries=0
  until osascript -e "tell application \"System Events\" to click at {$cx, $cy}" 2>/tmp/eduquest_tap_err; do
    tries=$((tries+1))
    if grep -q "not allowed assistive access" /tmp/eduquest_tap_err && [ "$tries" -lt 3 ]; then
      log "assistive access denied, retrying ($tries/3)..."
      sleep 1
      continue
    fi
    cat /tmp/eduquest_tap_err >&2
    log "TAP FAILED - grant Accessibility permission to the calling process in"
    log "System Settings > Privacy & Security > Accessibility, or drive manually."
    return 1
  done
}

cmd_swipe() {
  local udid="$1" x1="$2" y1="$3" x2="$4" y2="$5"
  osascript -e 'tell application "Simulator" to activate'
  sleep 0.4

  local shot="/tmp/eduquest_mobile_tapcalib.png"
  xcrun simctl io "$udid" screenshot "$shot" >/dev/null
  local shot_w shot_h
  shot_w=$(sips -g pixelWidth "$shot" | awk '/pixelWidth/{print $2}')
  shot_h=$(sips -g pixelHeight "$shot" | awk '/pixelHeight/{print $2}')

  local win
  win=$(osascript -e 'tell application "System Events" to tell process "Simulator" to get {position, size} of window 1')
  IFS=', ' read -r win_x win_y win_w win_h <<< "$win"

  local mapped
  mapped=$(python3 - "$win_x" "$win_y" "$win_w" "$win_h" "$shot_w" "$shot_h" "$x1" "$y1" "$x2" "$y2" <<'PY'
import sys
win_x, win_y, win_w, win_h, shot_w, shot_h, ox1, oy1, ox2, oy2 = map(float, sys.argv[1:11])
scale = win_h / shot_h
offset_x = (win_w - shot_w * scale) / 2
def conv(ox, oy):
    return win_x + offset_x + ox * scale, win_y + oy * scale
cx1, cy1 = conv(ox1, oy1)
cx2, cy2 = conv(ox2, oy2)
print(f"{cx1:.0f} {cy1:.0f} {cx2:.0f} {cy2:.0f}")
PY
)
  local cx1 cy1 cx2 cy2
  read -r cx1 cy1 cx2 cy2 <<< "$mapped"
  log "swiping window-space ($cx1,$cy1) -> ($cx2,$cy2) for screenshot-space ($x1,$y1) -> ($x2,$y2)"

  # A single smooth drag reads as a scroll gesture to the simulator; a few
  # intermediate dm: steps make it register reliably (a single dd:/du: pair
  # with no motion in between is sometimes swallowed as a tap instead).
  local midx1=$(( (cx1*3 + cx2) / 4 ))
  local midy1=$(( (cy1*3 + cy2) / 4 ))
  local midx2=$(( (cx1 + cx2*3) / 4 ))
  local midy2=$(( (cy1 + cy2*3) / 4 ))
  cliclick -w 30 dd:"$cx1","$cy1" dm:"$midx1","$midy1" dm:"$midx2","$midy2" dm:"$cx2","$cy2" du:"$cx2","$cy2"
}

# The app depends on the NestJS API + Ollama running locally. This repo
# tends to accumulate stale `nest start --watch` processes across sessions;
# more than one can end up bound to different ports with DIFFERENT code
# (see Gotchas). This just reports what's listening where so you can pick
# the right one for lib/core/network/dio_client.dart's baseUrl.
cmd_backend_check() {
  log "processes listening on common API ports:"
  lsof -iTCP -sTCP:LISTEN -P 2>/dev/null | grep node || true
  log ""
  log "quick schema check (expects 400 with an email/password validation"
  log "error, NOT a phone-based schema, NOT connection refused):"
  for port in 3000 3050; do
    echo "--- port $port ---"
    curl -s -X POST "http://127.0.0.1:$port/api/auth/login" \
      -H "Content-Type: application/json" -d '{}' || echo "(unreachable)"
    echo
  done
  log "ollama:"
  pgrep -fl "ollama serve" || log "ollama serve not running"
}

case "${1:-}" in
  build) cmd_build "$2" ;;
  launch) cmd_launch "$2" ;;
  screenshot) cmd_screenshot "$2" "$3" ;;
  tap) cmd_tap "$2" "$3" "$4" ;;
  swipe) cmd_swipe "$2" "$3" "$4" "$5" "$6" ;;
  backend-check) cmd_backend_check ;;
  *)
    echo "usage: $0 {build|launch|screenshot|tap|swipe|backend-check} [args...]" >&2
    exit 1
    ;;
esac
