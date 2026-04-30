import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/live/live_controller.dart';

const _channel = MethodChannel('speakr/tray');

/// Wires the native Windows tray menu's actions into the running Flutter
/// app. Today the only inbound method is `startRecording`, fired from the
/// "Start Recording" tray menu item; it forwards into [RecordingController]
/// which already guards against double-starts and auto-spawns the mini
/// recorder window.
void installTrayBridge(ProviderContainer container) {
  _channel.setMethodCallHandler((call) async {
    if (call.method == 'startRecording') {
      await container.read(recordingControllerProvider.notifier).start();
      return null;
    }
    return null;
  });
}
