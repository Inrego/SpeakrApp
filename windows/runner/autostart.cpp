#include "autostart.h"

#include <windows.h>

#include <string>

namespace {

constexpr const wchar_t kRunKeyPath[] =
    L"Software\\Microsoft\\Windows\\CurrentVersion\\Run";
// Value name under HKCU\...\Run. Kept stable across upgrades; do not change
// without also clearing the old name on first launch.
constexpr const wchar_t kRunValueName[] = L"SpeakrUpload";
// Argument the runner checks in main.cpp to skip the initial window Show().
constexpr const wchar_t kHiddenFlag[] = L"--hidden";

std::wstring GetExecutablePath() {
  // MAX_PATH is fine here: long-path support requires a manifest opt-in this
  // app does not currently set, and the runner is installed under standard
  // Program Files / user paths.
  wchar_t buffer[MAX_PATH] = {0};
  DWORD len = ::GetModuleFileNameW(nullptr, buffer, MAX_PATH);
  if (len == 0 || len >= MAX_PATH) return std::wstring();
  return std::wstring(buffer, len);
}

std::wstring BuildCommand() {
  std::wstring exe = GetExecutablePath();
  if (exe.empty()) return std::wstring();
  std::wstring cmd;
  cmd.reserve(exe.size() + 16);
  cmd.push_back(L'"');
  cmd.append(exe);
  cmd.push_back(L'"');
  cmd.push_back(L' ');
  cmd.append(kHiddenFlag);
  return cmd;
}

bool ReadEnabled() {
  HKEY key = nullptr;
  if (::RegOpenKeyExW(HKEY_CURRENT_USER, kRunKeyPath, 0, KEY_QUERY_VALUE,
                      &key) != ERROR_SUCCESS) {
    return false;
  }
  DWORD type = 0;
  DWORD size = 0;
  LONG status = ::RegQueryValueExW(key, kRunValueName, nullptr, &type, nullptr,
                                   &size);
  ::RegCloseKey(key);
  return status == ERROR_SUCCESS && (type == REG_SZ || type == REG_EXPAND_SZ);
}

bool WriteEnabled() {
  std::wstring command = BuildCommand();
  if (command.empty()) return false;

  HKEY key = nullptr;
  if (::RegCreateKeyExW(HKEY_CURRENT_USER, kRunKeyPath, 0, nullptr,
                        REG_OPTION_NON_VOLATILE, KEY_SET_VALUE, nullptr, &key,
                        nullptr) != ERROR_SUCCESS) {
    return false;
  }
  // Size in bytes including the trailing null.
  DWORD bytes = static_cast<DWORD>((command.size() + 1) * sizeof(wchar_t));
  LONG status = ::RegSetValueExW(
      key, kRunValueName, 0, REG_SZ,
      reinterpret_cast<const BYTE*>(command.c_str()), bytes);
  ::RegCloseKey(key);
  return status == ERROR_SUCCESS;
}

bool DeleteEnabled() {
  HKEY key = nullptr;
  if (::RegOpenKeyExW(HKEY_CURRENT_USER, kRunKeyPath, 0, KEY_SET_VALUE,
                      &key) != ERROR_SUCCESS) {
    // Treat a missing key as success — nothing to disable.
    return true;
  }
  LONG status = ::RegDeleteValueW(key, kRunValueName);
  ::RegCloseKey(key);
  return status == ERROR_SUCCESS || status == ERROR_FILE_NOT_FOUND;
}

}  // namespace

AutoStartChannel::AutoStartChannel(flutter::BinaryMessenger* messenger) {
  channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      messenger, "speakr/autostart",
      &flutter::StandardMethodCodec::GetInstance());
  channel_->SetMethodCallHandler(
      [this](const auto& call, auto result) {
        HandleMethodCall(call, std::move(result));
      });
}

AutoStartChannel::~AutoStartChannel() {
  if (channel_) {
    channel_->SetMethodCallHandler(nullptr);
  }
}

void AutoStartChannel::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  const std::string& method = call.method_name();
  if (method == "isEnabled") {
    result->Success(flutter::EncodableValue(ReadEnabled()));
    return;
  }
  if (method == "setEnabled") {
    const auto* arg = std::get_if<bool>(call.arguments());
    if (arg == nullptr) {
      result->Error("invalid_args", "setEnabled expects a bool");
      return;
    }
    bool ok = *arg ? WriteEnabled() : DeleteEnabled();
    if (!ok) {
      result->Error("registry_failed",
                    *arg ? "Could not write Run key"
                         : "Could not remove Run key");
      return;
    }
    result->Success(flutter::EncodableValue(ReadEnabled()));
    return;
  }
  result->NotImplemented();
}
