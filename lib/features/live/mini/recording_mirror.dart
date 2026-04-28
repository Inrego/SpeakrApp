import 'dart:async';
import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../recording_state.dart';
import 'mini_ipc.dart';
import 'mini_window_native.dart';

/// Lives in the mini window's Flutter engine. Mirrors [RecordingState]
/// pushed from the main engine and forwards user actions back as
/// command messages.
class RecordingMirror extends StateNotifier<RecordingState> {
  RecordingMirror() : super(const RecordingState()) {
    _registerHandler();
  }

  void _registerHandler() {
    try {
      DesktopMultiWindow.setMethodHandler(_handle);
    } catch (_) {
      // Embedder unavailable (tests); UI will render with default state.
    }
  }

  Future<dynamic> _handle(MethodCall call, int fromWindowId) async {
    switch (call.method) {
      case MiniIpc.stateUpdate:
        try {
          final raw = call.arguments;
          final json = raw is String
              ? jsonDecode(raw) as Map<String, dynamic>
              : Map<String, dynamic>.from(raw as Map);
          state = RecordingState.fromJson(json);
        } catch (_) {}
        return null;
      case MiniIpc.lifecycleClose:
        // Main is closing us; the host window will be destroyed shortly.
        await MiniWindowNative.closeMini();
        return null;
    }
    return null;
  }

  // ----- Forward user actions to the main engine -----

  Future<dynamic> _send(String method, [Map<String, dynamic>? args]) async {
    try {
      return await DesktopMultiWindow.invokeMethod(
        MiniIpc.mainWindowId,
        method,
        args,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> togglePause() => _send(MiniIpc.cmdTogglePause);
  Future<void> stop() => _send(MiniIpc.cmdStop);
  Future<void> cancel() => _send(MiniIpc.cmdCancel);
  Future<void> setSpeakers(int v) =>
      _send(MiniIpc.cmdSetSpeakers, {'value': v});
  Future<void> toggleTag(String name) =>
      _send(MiniIpc.cmdToggleTag, {'name': name});
  Future<void> addCustomTag(String name) =>
      _send(MiniIpc.cmdAddCustomTag, {'name': name});
  Future<void> beginDrag() => _send(MiniIpc.cmdBeginDrag);
}

final recordingMirrorProvider =
    StateNotifierProvider<RecordingMirror, RecordingState>(
  (_) => RecordingMirror(),
);
