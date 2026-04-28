import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/live/live_controller.dart';
import 'auto_record_coordinator.dart';
import 'auto_record_providers.dart';

/// Singleton entry point for the auto-record subsystem. Constructed
/// once in [main] (Windows-only) and disposed when the process exits.
///
/// Ownership is intentionally outside the Riverpod graph so the
/// subsystem is alive even when no widgets are mounted (e.g. during the
/// splash gate before credentials resolve).
class AutoRecordBootstrap {
  AutoRecordBootstrap._(this.coordinator);

  final AutoRecordCoordinator coordinator;

  static AutoRecordBootstrap? _instance;
  static AutoRecordBootstrap? get instance => _instance;

  /// Initializes the auto-record subsystem on Windows. No-ops on other
  /// platforms. Safe to call multiple times — only the first wins.
  static Future<AutoRecordBootstrap?> start(ProviderContainer container) async {
    if (!Platform.isWindows) return null;
    if (_instance != null) return _instance;
    try {
      // Force the providers to materialize so the singletons live for
      // the app's lifetime, not just while a widget watches them.
      final store =
          await container.read(autoRecordStoreProvider.future);
      final monitor = container.read(micMonitorProvider);
      final meter = container.read(outputMeterProvider);
      final recording = container.read(recordingControllerProvider.notifier);

      final coordinator = AutoRecordCoordinator(
        micMonitor: monitor,
        outputMeter: meter,
        recording: recording,
        startRecording: recording.start,
        stopAndUpload: recording.stopAndUpload,
        cancelRecording: recording.cancel,
        store: store,
        onSettingsChanged: () =>
            container.invalidate(autoRecordSettingsProvider),
      );
      coordinator.start();
      _instance = AutoRecordBootstrap._(coordinator);
      // Re-publish via the override so consumers can watch it.
      // (We can't override after creation, so consumers should reach
      //  through `AutoRecordBootstrap.instance?.coordinator` instead.)
      return _instance;
    } catch (e, st) {
      debugPrint('[auto-record] bootstrap failed: $e\n$st');
      return null;
    }
  }

  Future<void> dispose() async {
    await coordinator.dispose();
    _instance = null;
  }
}

/// Synchronous accessor used by the UI. Returns null on non-Windows or
/// before bootstrap completes.
final autoRecordCoordinatorProvider = Provider<AutoRecordCoordinator?>((ref) {
  return AutoRecordBootstrap.instance?.coordinator;
});

/// Stop-prompt stream the app shell listens to. Empty stream when
/// bootstrap hasn't run.
final autoRecordPromptsProvider =
    StreamProvider<StopPromptRequest>((ref) async* {
  final coord = ref.watch(autoRecordCoordinatorProvider);
  if (coord == null) {
    yield* const Stream<StopPromptRequest>.empty();
    return;
  }
  yield* coord.prompts;
});
