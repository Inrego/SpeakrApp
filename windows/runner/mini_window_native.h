#ifndef RUNNER_MINI_WINDOW_NATIVE_H_
#define RUNNER_MINI_WINDOW_NATIVE_H_

#include <flutter/flutter_view_controller.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include <memory>

// Win32 helper that registers the `speakr/mini_window_native` MethodChannel
// on the main Flutter engine. It enforces always-on-top, tool-window styles,
// and a fixed compact frame on the secondary (mini-recorder) sub-window
// created via the desktop_multi_window plugin. The same channel also exposes
// `setMainWindowTitle` so Dart can rewrite the main HWND's caption (used in
// dev mode to differentiate worktrees).
class MiniWindowNative {
 public:
  MiniWindowNative(flutter::FlutterEngine* engine, HWND main_hwnd);
  ~MiniWindowNative();

  // Called by the host FlutterWindow's MessageHandler. Returns true if the
  // message was consumed by this helper (currently only WM_TIMER for the
  // retry-apply loop).
  bool HandleWindowMessage(HWND hwnd, UINT message, WPARAM wparam,
                           LPARAM lparam);

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  void ScheduleApply(int width, int height);
  void TryApplyOnce();
  HWND FindMiniHwnd();

  HWND main_hwnd_;
  int pending_width_ = 248;
  int pending_height_ = 40;
  int apply_attempts_ = 0;
  bool apply_in_progress_ = false;

  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;
};

#endif  // RUNNER_MINI_WINDOW_NATIVE_H_
