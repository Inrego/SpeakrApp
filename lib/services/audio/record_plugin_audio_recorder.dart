import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import 'live_audio_recorder.dart';

/// Mic-only fallback used on iOS and the web. Wraps the existing
/// `record: ^6.2.0` plugin. The system-audio toggle is hard-disabled
/// on this implementation; the mic toggle is mapped to pause/resume
/// because the underlying plugin cannot inject silence into a live
/// stream.
class RecordPluginAudioRecorder implements LiveAudioRecorder {
  final AudioRecorder _recorder = AudioRecorder();

  @override
  bool get supportsSystemAudio => false;

  @override
  bool get supportsLiveMicToggle => false;

  @override
  Stream<double> get audioLevel => _recorder
      .onAmplitudeChanged(const Duration(milliseconds: 50))
      .map((a) {
        // record returns dBFS in `a.current` (≤0 dB, with −160 ≈ silence).
        // dB-linear VU mapping: −55 dBFS → 0, −12 dBFS → 1. Matches the
        // Windows / Android native sides so the breathing dot reads the
        // same on every platform.
        final db = a.current;
        if (db.isNaN || db.isInfinite || db <= -120) return 0.0;
        const floorDb = -55.0;
        const ceilDb = -12.0;
        final v = (db - floorDb) / (ceilDb - floorDb);
        if (v.isNaN || v <= 0) return 0.0;
        if (v >= 1.0) return 1.0;
        return v;
      });

  @override
  Future<bool> isRecording() => _recorder.isRecording();

  @override
  Future<bool> hasMicPermission() => _recorder.hasPermission();

  @override
  Future<bool> requestMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  @override
  Future<bool> requestSystemPermission() async => false;

  @override
  Future<void> start({
    required String path,
    required bool micEnabled,
    required bool systemEnabled,
  }) async {
    if (systemEnabled) {
      throw UnsupportedError(
          'System audio capture is not supported on this platform.');
    }
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: path,
    );
    if (!micEnabled) {
      // No live-mute support — start then immediately pause so the
      // file timeline accurately reflects "mic off from t=0". The
      // user can toggle mic on later, which resumes the encoder.
      await _recorder.pause();
    }
  }

  @override
  Future<void> pause() => _recorder.pause();

  @override
  Future<void> resume() => _recorder.resume();

  @override
  Future<void> setMicEnabled(bool enabled) async {
    if (enabled) {
      await _recorder.resume();
    } else {
      await _recorder.pause();
    }
  }

  @override
  Future<void> setSystemEnabled(bool enabled) async {
    if (enabled) {
      throw UnsupportedError(
          'System audio capture is not supported on this platform.');
    }
    // Disabling a never-enabled source is a no-op.
  }

  @override
  Future<String?> stop() => _recorder.stop();

  @override
  Future<void> dispose() async {
    try {
      await _recorder.dispose();
    } catch (e) {
      debugPrint('RecordPluginAudioRecorder.dispose: $e');
    }
  }
}
