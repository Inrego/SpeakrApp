#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>

#include <memory>

#include "mini_window_native.h"
#include "tray_icon.h"
#include "win32_window.h"

// A window that does nothing but host a Flutter view.
class FlutterWindow : public Win32Window {
 public:
  // Creates a new FlutterWindow hosting a Flutter view running |project|.
  explicit FlutterWindow(const flutter::DartProject& project);
  virtual ~FlutterWindow();

 protected:
  // Win32Window:
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND window, UINT const message, WPARAM const wparam,
                         LPARAM const lparam) noexcept override;

 private:
  // Tears down the tray icon and destroys the window so the message loop
  // exits. Invoked from the tray "Exit" menu item.
  void RequestExit();

  // The project to run.
  flutter::DartProject project_;

  // The Flutter instance hosted by this window.
  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;

  // Optional helper that drives the always-on-top mini recorder window
  // on Windows. Constructed after RegisterPlugins() in OnCreate().
  std::unique_ptr<MiniWindowNative> mini_window_native_;

  // Owns the system-tray icon. Constructed after the HWND exists.
  std::unique_ptr<TrayIcon> tray_icon_;

  // True once a real exit has been requested (tray "Exit"). While false,
  // WM_CLOSE hides the window instead of destroying it.
  bool force_quit_ = false;
};

#endif  // RUNNER_FLUTTER_WINDOW_H_
