#include "mini_window_native.h"

#include <flutter/encodable_value.h>

#include <string>
#include <variant>

namespace {

// Custom timer id used on the main HWND to drive the retry-apply loop.
constexpr UINT_PTR kApplyTimerId = 0x53504B41;  // 'SPKA'

int IntFromEncodable(const flutter::EncodableValue& v, int fallback) {
  if (const auto* i = std::get_if<int32_t>(&v)) return *i;
  if (const auto* l = std::get_if<int64_t>(&v)) return static_cast<int>(*l);
  if (const auto* d = std::get_if<double>(&v)) return static_cast<int>(*d);
  return fallback;
}

}  // namespace

MiniWindowNative::MiniWindowNative(flutter::FlutterEngine* engine,
                                     HWND main_hwnd)
    : main_hwnd_(main_hwnd) {
  channel_ = std::make_unique<
      flutter::MethodChannel<flutter::EncodableValue>>(
      engine->messenger(),
      "speakr/mini_window_native",
      &flutter::StandardMethodCodec::GetInstance());
  channel_->SetMethodCallHandler(
      [this](const auto& call, auto result) {
        HandleMethodCall(call, std::move(result));
      });
}

MiniWindowNative::~MiniWindowNative() {
  if (apply_in_progress_) {
    ::KillTimer(main_hwnd_, kApplyTimerId);
    apply_in_progress_ = false;
  }
}

void MiniWindowNative::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  const auto& method = call.method_name();
  if (method == "applyMiniChrome") {
    int width = 248;
    int height = 40;
    if (const auto* args =
            std::get_if<flutter::EncodableMap>(call.arguments())) {
      auto wit = args->find(flutter::EncodableValue("width"));
      if (wit != args->end()) width = IntFromEncodable(wit->second, width);
      auto hit = args->find(flutter::EncodableValue("height"));
      if (hit != args->end()) height = IntFromEncodable(hit->second, height);
    }
    ScheduleApply(width, height);
    result->Success();
    return;
  }
  if (method == "closeMini") {
    HWND mini = FindMiniHwnd();
    if (mini != nullptr) {
      ::PostMessage(mini, WM_CLOSE, 0, 0);
    }
    result->Success();
    return;
  }
  if (method == "focusMain") {
    // Main window may be hidden (close-to-tray) or minimized. SW_SHOW
    // brings a hidden window back; SW_RESTORE unminimizes. Mirrors
    // BringWindowToForegroundImpl in flutter_window.cpp.
    if (main_hwnd_ != nullptr) {
      ::ShowWindow(main_hwnd_, SW_SHOW);
      if (::IsIconic(main_hwnd_)) {
        ::ShowWindow(main_hwnd_, SW_RESTORE);
      }
      ::SetForegroundWindow(main_hwnd_);
    }
    result->Success();
    return;
  }
  if (method == "beginMiniDrag") {
    // Hand the mini window over to Windows' built-in title-bar move loop.
    // Requires the LMB to currently be down on the user's side; the IPC
    // round-trip is sub-ms, so a click-drag from the in-app top bar
    // reaches here while the button is still pressed.
    HWND mini = FindMiniHwnd();
    if (mini != nullptr) {
      ::ReleaseCapture();
      ::PostMessage(mini, WM_NCLBUTTONDOWN, HTCAPTION, 0);
    }
    result->Success();
    return;
  }
  if (method == "setMainWindowTitle") {
    const auto* args = std::get_if<flutter::EncodableMap>(call.arguments());
    if (args == nullptr) {
      result->Error("bad_args", "expected map with 'title'");
      return;
    }
    auto it = args->find(flutter::EncodableValue("title"));
    if (it == args->end()) {
      result->Error("bad_args", "missing 'title'");
      return;
    }
    const auto* title_utf8 = std::get_if<std::string>(&it->second);
    if (title_utf8 == nullptr) {
      result->Error("bad_args", "'title' must be a string");
      return;
    }
    int wide_len = ::MultiByteToWideChar(CP_UTF8, 0, title_utf8->c_str(),
                                         static_cast<int>(title_utf8->size()),
                                         nullptr, 0);
    std::wstring wide(wide_len, L'\0');
    if (wide_len > 0) {
      ::MultiByteToWideChar(CP_UTF8, 0, title_utf8->c_str(),
                            static_cast<int>(title_utf8->size()), wide.data(),
                            wide_len);
    }
    ::SetWindowTextW(main_hwnd_, wide.c_str());
    result->Success();
    return;
  }
  result->NotImplemented();
}

void MiniWindowNative::ScheduleApply(int width, int height) {
  pending_width_ = width;
  pending_height_ = height;
  apply_attempts_ = 0;
  apply_in_progress_ = true;
  TryApplyOnce();
  if (apply_in_progress_) {
    ::SetTimer(main_hwnd_, kApplyTimerId, 50, nullptr);
  }
}

bool MiniWindowNative::HandleWindowMessage(HWND /*hwnd*/, UINT message,
                                            WPARAM wparam, LPARAM /*lparam*/) {
  if (message == WM_TIMER && wparam == kApplyTimerId) {
    TryApplyOnce();
    if (!apply_in_progress_) {
      ::KillTimer(main_hwnd_, kApplyTimerId);
    }
    return true;
  }
  return false;
}

void MiniWindowNative::TryApplyOnce() {
  if (!apply_in_progress_) return;
  apply_attempts_++;
  HWND mini = FindMiniHwnd();
  if (mini == nullptr) {
    if (apply_attempts_ > 60) {  // ~3 seconds total
      apply_in_progress_ = false;
    }
    return;
  }

  // Borderless: drop the OS title bar entirely. The mini's in-app top
  // row is the close affordance and (via beginMiniDrag) the drag handle.
  LONG style = ::GetWindowLong(mini, GWL_STYLE);
  style &= ~(WS_THICKFRAME | WS_MAXIMIZEBOX | WS_MINIMIZEBOX | WS_CAPTION |
             WS_SYSMENU | WS_BORDER | WS_DLGFRAME);
  style |= WS_POPUP;
  ::SetWindowLong(mini, GWL_STYLE, style);

  LONG ex = ::GetWindowLong(mini, GWL_EXSTYLE);
  ex |= WS_EX_TOOLWINDOW | WS_EX_TOPMOST;
  ex &= ~WS_EX_APPWINDOW;
  ::SetWindowLong(mini, GWL_EXSTYLE, ex);

  // Place top-right of the main window's monitor with a 24px margin.
  HMONITOR mon = ::MonitorFromWindow(main_hwnd_, MONITOR_DEFAULTTOPRIMARY);
  MONITORINFO mi;
  mi.cbSize = sizeof(MONITORINFO);
  ::GetMonitorInfo(mon, &mi);
  int x = mi.rcWork.right - pending_width_ - 24;
  int y = mi.rcWork.top + 24;

  ::SetWindowPos(mini, HWND_TOPMOST, x, y, pending_width_, pending_height_,
                 SWP_NOACTIVATE | SWP_FRAMECHANGED | SWP_SHOWWINDOW);

  // Clip the window to a rounded rectangle so the dark pill body has true
  // rounded corners on the desktop (CreateRoundRectRgn uses inclusive
  // coordinates, hence the +1). Windows takes ownership of the region.
  const int kCornerDiameter = 40;
  HRGN rgn = ::CreateRoundRectRgn(0, 0, pending_width_ + 1,
                                  pending_height_ + 1, kCornerDiameter,
                                  kCornerDiameter);
  ::SetWindowRgn(mini, rgn, TRUE);

  apply_in_progress_ = false;
}

HWND MiniWindowNative::FindMiniHwnd() {
  struct EnumCtx {
    DWORD pid;
    HWND main;
    HWND result;
  };
  EnumCtx ctx{::GetCurrentProcessId(), main_hwnd_, nullptr};
  ::EnumWindows(
      [](HWND hwnd, LPARAM lp) -> BOOL {
        auto& c = *reinterpret_cast<EnumCtx*>(lp);
        if (hwnd == c.main) return TRUE;
        DWORD wpid = 0;
        ::GetWindowThreadProcessId(hwnd, &wpid);
        if (wpid != c.pid) return TRUE;
        if (!::IsWindowVisible(hwnd)) return TRUE;
        // Skip owned windows (tooltips, menus, dialogs); we want only
        // top-level application windows.
        if (::GetWindow(hwnd, GW_OWNER) != nullptr) return TRUE;
        c.result = hwnd;
        return FALSE;
      },
      reinterpret_cast<LPARAM>(&ctx));
  return ctx.result;
}
