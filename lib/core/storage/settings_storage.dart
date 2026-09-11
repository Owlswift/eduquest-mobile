import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Small local (per-device) preferences - not synced to the backend.
class SettingsStorage {
  final _storage = const FlutterSecureStorage();
  static const _pushEnabledKey = 'push_notifications_enabled';

  /// Defaults to enabled - a student who's never touched the toggle keeps
  /// getting push, matching the default behavior before this setting existed.
  Future<bool> getPushEnabled() async {
    final value = await _storage.read(key: _pushEnabledKey);
    return value != 'false';
  }

  Future<void> setPushEnabled(bool enabled) async {
    await _storage.write(key: _pushEnabledKey, value: enabled ? 'true' : 'false');
  }
}
