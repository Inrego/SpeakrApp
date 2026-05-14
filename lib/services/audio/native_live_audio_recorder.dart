import 'dart:async';

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

  // Poll cadence for the audio level — ~20 Hz matches the design's
  // breathing-dot animation. Native side buffers the latest RMS-derived
  // level; we pull it via `getLevel` so we don't need an EventChannel
  // (whose sinks can only fire on the platform thread on Windows).
  static const Duration _levelPollInterval = Duration(milliseconds: 50);

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
  Stream<double> get audioLevel {
    // One controller per listener, so each subscription gets its own
    // polling timer. The controller is closed (and the timer cancelled)
    // automatically when the subscription is cancelled.
    late StreamController<double> controller;
    Timer? timer;

    Future<void> tick() async {
      try {
        final v = await _channel.invokeMethod<double>('getLevel');
        if (controller.isClosed) return;
        final clamped = (v ?? 0.0).clamp(0.0, 1.0);
        controller.add(clamped);
      } catch (_) {
        // MissingPlugin or platform error — emit silence so subscribers
        // don't see stale values.
        if (!controller.isClosed) controller.add(0.0);
      }
    }

    controller = StreamController<double>(
      onListen: () {
        timer = Timer.periodic(_levelPollInterval, (_) => tick());
        // Kick an immediate sample so the meter isn't blank for the
        // first poll interval after the listener attaches.
        tick();
      },
      onCancel: () async {
        timer?.cancel();
        timer = null;
      },
    );
    return controller.stream;
  }

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
