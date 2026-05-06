import 'dart:io';

import 'package:flutter/services.dart';

/// Talks to the native `speakr/autostart` MethodChannel (see
/// [windows/runner/autostart.cpp](windows/runner/autostart.cpp)) which
/// reads/writes a per-user `HKCU\…\Run` registry value. Every method
/// no-ops on non-Windows platforms — there is no equivalent registration
/// path on Android/iOS today.
class AutoStartService {
  AutoStartService();

  static const _channel = MethodChannel('speakr/autostart');

  bool get supported => Platform.isWindows;

  Future<bool> isEnabled() async {
    if (!supported) return false;
    final result = await _channel.invokeMethod<bool>('isEnabled');
    return result ?? false;
  }

  Future<bool> setEnabled(bool value) async {
    if (!supported) return false;
    final result = await _channel.invokeMethod<bool>('setEnabled', value);
    return result ?? false;
  }
}
