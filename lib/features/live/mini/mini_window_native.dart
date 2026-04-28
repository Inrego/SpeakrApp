import 'package:flutter/services.dart';

/// Dart-side wrapper around the native Win32 helper registered in
/// `windows/runner/mini_window_native.cpp`. The helper applies always-on-top,
/// `WS_EX_TOOLWINDOW`, and a fixed compact frame to whichever top-level
/// window in this process is *not* the main app window.
///
/// All methods are no-ops on non-Windows platforms.
class MiniWindowNative {
  MiniWindowNative._();

  static const _channel = MethodChannel('speakr/mini_window_native');

  /// Apply always-on-top, no-taskbar, fixed size, and place the window in
  /// the top-right of the primary monitor. Safe to call multiple times.
  static Future<void> applyMiniChrome({
    int width = 320,
    int height = 540,
  }) async {
    try {
      await _channel.invokeMethod('applyMiniChrome', {
        'width': width,
        'height': height,
      });
    } on MissingPluginException {
      // Helper not registered (non-Windows or older runner build) — silent.
    } catch (_) {
      // Don't let a chrome failure break recording.
    }
  }

  /// Send WM_CLOSE to the mini window. Safe if the window is already gone.
  static Future<void> closeMini() async {
    try {
      await _channel.invokeMethod('closeMini');
    } on MissingPluginException {
      // ignore
    } catch (_) {}
  }

  /// Hand the mini window over to Windows' move loop. Call while the LMB
  /// is still held by the user — the OS picks the drag up from the
  /// current cursor position.
  static Future<void> beginMiniDrag() async {
    try {
      await _channel.invokeMethod('beginMiniDrag');
    } on MissingPluginException {
      // ignore
    } catch (_) {}
  }
}
