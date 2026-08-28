---
name: run-mobile
description: Build, launch, and drive the EduQuest Flutter app (apps/mobile) on an iOS Simulator - use when asked to run, launch, screenshot, or interact with the mobile app, or to verify a Flutter change actually works end-to-end.
---

# Running EduQuest mobile (Flutter)

All paths below are relative to `apps/mobile/` (this skill's grandparent
directory). The driver is `.claude/skills/run-mobile/driver.sh`.

This app is a client for the NestJS API in `apps/api` - it needs that
API (and, for the AI Tutor feature, a local Ollama model) running
before it's useful. See **Backend dependency** below before you launch.

## Prerequisites

- Xcode + an iOS Simulator runtime installed, at least one device created.
- `flutter` on PATH (this repo uses Flutter/Dart per `pubspec.yaml`'s
  `sdk: ^3.12.2`).
- The API running (`apps/api`) and reachable from the simulator - see
  **Backend dependency**.
- `python3` (stdlib only) - used by the driver for coordinate math.

Get a booted simulator UDID:

```bash
xcrun simctl list devices | grep Booted
# or boot one:
xcrun simctl list devicetypes | grep "iPhone 17 Pro Max"
xcrun simctl boot "4A78DD0D-52B5-4CBB-BF13-0904500D749F"   # example UDID
```

## Backend dependency (read this first)

`lib/core/network/dio_client.dart` hardcodes a `baseUrl`. This repo
tends to accumulate **multiple stale `nest start --watch` / compiled
`dist` processes** bound to different ports, and they are not
guaranteed to be running the same code. Before pointing the app at a
port, run:

```bash
.claude/skills/run-mobile/driver.sh backend-check
```

This lists what's listening on the usual ports and POSTs an empty body
to `/api/auth/login` on 3000 and 3050 - a healthy, current backend
replies `400` with an **email/password** validation error. If you see
a **phone-based** schema instead, that process is running old code;
find the port that answers with `email`/`password` and use that one in
`dio_client.dart`. It also checks `ollama serve` is up (required for
the AI Tutor feature - `/tutor/sessions` calls a local LLM and can take
15-45s to respond).

If `dio_client.dart`'s `baseUrl` doesn't match a live, current-code
port, everything below will either connect-refuse or 400 on login.

## Run (agent path)

```bash
UDID="4A78DD0D-52B5-4CBB-BF13-0904500D749F"   # your booted device
cd apps/mobile

# first run / after pubspec changes:
.claude/skills/run-mobile/driver.sh build "$UDID"
# ^ runs in the foreground and streams flutter's interactive session -
#   prefer `launch` (below) for anything scripted.

# (re)launch in the background after a code change - waits for the
# Dart VM Service line before returning, ~20-30s typical:
.claude/skills/run-mobile/driver.sh launch "$UDID"

# screenshot (native device resolution, e.g. 1320x2868 for iPhone 17 Pro Max):
.claude/skills/run-mobile/driver.sh screenshot "$UDID" /tmp/shot.png
# then actually look at it - Read the PNG, don't just check the command succeeded.

# tap - coordinates are ORIGINAL PIXELS measured on a screenshot you just took,
# NOT the coordinates of some other scaled preview of it:
.claude/skills/run-mobile/driver.sh tap "$UDID" 804 193
```

`launch` reinstalls the app, which can wipe the secure-storage session
token (observed inconsistently across simulator/Xcode versions) - after
`launch` you may land back on onboarding instead of the dashboard even
if you were logged in before. Log in again with a test account if so.

Text input (typing into a field) has no driver command - `System
Events` can `keystroke` into whatever currently has focus after a
`tap` puts the cursor there:

```bash
osascript -e 'tell application "Simulator" to activate'
osascript -e 'tell application "System Events" to keystroke "hello"'
```

### How `tap` works (read before debugging a "nothing happened" tap)

`xcrun simctl` has **no tap-injection command**. The driver instead
clicks the Simulator.app **window** via `System Events`, which the
simulator forwards as a touch event. Two things follow from this:

1. **Accessibility permission is required.** The process actually
   invoking `osascript` (not "Terminal", not "Simulator" - whatever
   spawned the shell, e.g. Claude Code's own binary) must be added and
   enabled under System Settings > Privacy & Security > Accessibility.
   This is a one-time GUI grant a human must make; nothing scriptable
   does it. **A newly-granted permission does not apply to an
   already-running process** - if the calling process was already
   alive when the grant happened, `osascript` keeps failing with `-25211
   not allowed assistive access` until that process restarts. If you
   hit this mid-session and can't restart, ask the user to drive the
   UI manually and screenshot after each of their steps instead.
2. **Screenshot pixels != window points.** The Simulator window's
   bounds (`System Events ... get {position, size} of window 1`) are
   in points; screenshots are native device pixels. The driver maps
   screenshot pixel `(ox, oy)` to a window-space click via:
   ```
   scale    = window_height_pt / screenshot_height_px
   offset_x = (window_width_pt - screenshot_width_px * scale) / 2
   click_x  = window_x + offset_x + ox * scale
   click_y  = window_y + oy * scale
   ```
   Derived empirically (matched a screenshot's aspect ratio against
   the window's aspect ratio - the width has ~4pt of side border on
   each side, the height has none, i.e. no separate title bar). Verified
   accurate to within a button's hit-target on iPhone 17 Pro Max /
   iOS 26.5 / Xcode's default (non-bezel) Simulator window style.

## Run (human path)

```bash
cd apps/mobile
flutter run -d "$UDID"
```
Opens the app in the simulator; `r`/`R` in that terminal hot-reload/restart.
Useless for unattended/scripted verification since it blocks on stdin.

## Gotchas

- **`record` package version-resolution bug**: `record: ^5.2.1` (as
  originally pinned) resolves an internally-inconsistent set of the
  package's federated platform implementations, causing a kernel-compile
  error (`RecordLinux` missing `startStream`) even when targeting iOS,
  not Linux. Fixed by bumping to `record: ^7.1.1` in `pubspec.yaml` -
  resolves a consistent 2.x family and splits `record_darwin` into
  `record_ios`/`record_macos`.
- **iOS ATS blocks plain HTTP** to a non-`localhost` dev backend by
  default. `ios/Runner/Info.plist` has an `NSAppTransportSecurity`
  exception scoped to `localhost` only - if you point `baseUrl` at a
  LAN IP instead of `localhost`/`127.0.0.1`, you need a broader
  exception (or an HTTPS backend) or requests fail silently/timeout.
  As shipped, this app talks to a LAN IP successfully anyway (verified
  in this session) - simulator networking is more permissive than a
  real device here; don't assume the same works on a physical iPhone
  without revisiting this.
- **Backend request timeouts**: `DioClient`'s global default is a 10s
  `receiveTimeout`. The Tutor Engine's `POST /tutor/sessions` and
  `POST /tutor/sessions/:id/messages` call a local LLM and routinely
  take 15-30s. `tutor_service.dart` overrides these two calls to 45s -
  if you add a new endpoint that hits an LLM/local-model backend,
  override its timeout too or you'll see "That took too long to
  respond" on a perfectly healthy backend.
- **Multiple stale API processes** (see Backend dependency above) -
  don't assume "a server answers on port 3000" means it's the right
  one.
- **Docker containers for Postgres/Redis stop silently** across
  machine restarts (`docker ps -a` shows `Exited`). If the API 500s on
  basically everything, check `docker start eduquest-postgres
  eduquest-redis` before debugging app code.
- **`flutter run` after `pkill` + relaunch can drop the secure-storage
  session** - don't assume a relaunch preserves login state; screenshot
  and check.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `osascript ... not allowed assistive access (-25211)` | Grant Accessibility permission to the calling process in System Settings; if already granted, the process needs to restart to pick it up (see "How tap works" above) - fall back to asking the user to tap manually. |
| `RecordLinux` missing `startStream` at build time | Bump `record` to `^7.1.1`+ in `pubspec.yaml`, `flutter pub get`. |
| Login 400s with `"property email should not exist","phone must be a string"` | You're pointed at a stale backend process serving an old `LoginDto`. Run `driver.sh backend-check`, point `dio_client.dart` at the port that returns the email/password schema. |
| App hangs on "Preparing your lesson..." then errors "took too long to respond" | The relevant Dio call is missing a longer `receiveTimeout` override for an LLM-backed endpoint - see Gotchas. |
| Everything 500s / connection refused right after a machine restart | `docker ps -a`, then `docker start eduquest-postgres eduquest-redis`. |
| `flutter run` fails on `record_darwin` Swift Package Manager warning | Harmless warning, not the actual failure - check further down the log for the real compile error (usually the `record` version issue above). |
