import 'package:shared_preferences/shared_preferences.dart';

import 'time_format_preference.dart';

/// SharedPreferences-backed persistence for the time-format preference.
/// Mirrors the shape of [AutoRecordSettingsStore] — single key, async open.
class TimeFormatStore {
  TimeFormatStore(this._prefs);

  final SharedPreferences _prefs;

  static const _kKey = 'preferences.time_format';

  static Future<TimeFormatStore> open() async =>
      TimeFormatStore(await SharedPreferences.getInstance());

  TimeFormatPreference read() =>
      TimeFormatPreference.fromStorage(_prefs.getString(_kKey));

  Future<void> write(TimeFormatPreference next) async {
    await _prefs.setString(_kKey, next.storageValue);
  }
}
