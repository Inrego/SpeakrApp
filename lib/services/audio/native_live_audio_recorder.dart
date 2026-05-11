import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'live_audio_recorder.dart';

/// Shared Dart-side wrapper for the native Speakr recorder (Windows
/// WASAPI, Android MediaProjection). Both platforms expose the same
/// `MethodChannel("speakr.audio/recorder")` surface so we keep a single
/// Dart implementation; per-platform differences (e.g. Android's
/// per-session consent flow) live in the native code.
class NativeLiveAudioRecorder implements LiveAudioRecorder {
  NativeLiveAudioRecorder._(this._supportsSystemAudio);

  static const MethodChannel _channel = MethodChannel('speakr.audio/recorder');

  final bool _supportsSystemAudio;

  static Future<NativeLiveAudioRecorder> probe() async {
    bool supports = false;
    try {
      final result = await _channel.invokeMethod<bool>('supportsSystemAudio');
      supports = result ?? false;
    } on MissingPluginException {
      supports = false;
    } catch (_) {
      supports = false;
    }
    return NativeLiveAudioRecorder._(supports);
  }

  @override
  bool get supportsSystemAudio => _supportsSystemAudio;

  @override
  bool get supportsLiveMicToggle => true;

  @override
  Future<bool> isRecording() async {
    try {
      final r = await _channel.invokeMethod<bool>('isRecording');
      return r ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> hasMicPermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  @override
  Future<bool> requestMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  @override
  Future<bool> requestSystemPermission() async {
    if (!_supportsSystemAudio) return false;
    try {
      final r = await _channel.invokeMethod<bool>('requestSystemPermission');
      return r ?? false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<void> start({
    required String path,
    required bool micEnabled,
    required bool systemEnabled,
  }) async {
    if (systemEnabled && !_supportsSystemAudio) {
      throw UnsupportedError(
          'System audio capture is not supported on this platform.');
    }
    await _channel.invokeMethod<void>('start', <String, dynamic>{
      'path': path,
      'micEnabled': micEnabled,
      'systemEnabled': systemEnabled,
    });
  }

  @override
  Future<void> pause() async {
    await _channel.invokeMethod<void>('pause');
  }

  @override
  Future<void> resume() async {
    await _channel.invokeMethod<void>('resume');
  }

  @override
  Future<void> setMicEnabled(bool enabled) async {
    await _channel.invokeMethod<void>(
      'setMicEnabled',
      <String, dynamic>{'enabled': enabled},
    );
  }

  @override
  Future<void> setSystemEnabled(bool enabled) async {
    if (enabled && !_supportsSystemAudio) {
      throw UnsupportedError(
          'System audio capture is not supported on this platform.');
    }
    await _channel.invokeMethod<void>(
      'setSystemEnabled',
      <String, dynamic>{'enabled': enabled},
    );
  }

  @override
  Future<String?> stop() async {
    try {
      return await _channel.invokeMethod<String>('stop');
    } on PlatformException catch (e) {
      throw Exception(e.message ?? 'Recorder failed to stop.');
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await _channel.invokeMethod<void>('dispose');
    } catch (_) {}
  }
}
