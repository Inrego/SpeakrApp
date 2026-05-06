#ifndef RUNNER_AUTOSTART_H_
#define RUNNER_AUTOSTART_H_

#include <flutter/binary_messenger.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <memory>

// Wires a `speakr/autostart` MethodChannel that lets the Dart settings UI
// query and toggle the per-user Windows Run key registration. Enabling it
// writes the running executable's path with a `--hidden` argument so that
// auto-launched instances drop straight into the tray.
class AutoStartChannel {
 public:
  explicit AutoStartChannel(flutter::BinaryMessenger* messenger);
  ~AutoStartChannel();

  AutoStartChannel(const AutoStartChannel&) = delete;
  AutoStartChannel& operator=(const AutoStartChannel&) = delete;

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;
};

#endif  // RUNNER_AUTOSTART_H_
