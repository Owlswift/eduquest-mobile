import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists which upcoming competitions the student has asked to be
/// reminded about. Device-local only - there's no push-notification
/// backend yet, so this doesn't schedule an OS alert, it just remembers
/// the choice (and is what "Notify Me" / "Reminder Set" reflects).
class CompetitionReminderStore {
  final _storage = const FlutterSecureStorage();
  static const _key = 'competition_reminders';

  Future<Set<String>> _readAll() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return {};
    return raw.split(',').toSet();
  }

  Future<void> _writeAll(Set<String> ids) async {
    await _storage.write(key: _key, value: ids.join(','));
  }

  Future<bool> isSet(String competitionId) async {
    return (await _readAll()).contains(competitionId);
  }

  /// Flips the reminder for [competitionId] and returns the new state.
  Future<bool> toggle(String competitionId) async {
    final ids = await _readAll();
    final nowSet = !ids.contains(competitionId);
    if (nowSet) {
      ids.add(competitionId);
    } else {
      ids.remove(competitionId);
    }
    await _writeAll(ids);
    return nowSet;
  }
}
