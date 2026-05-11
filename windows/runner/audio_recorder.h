#ifndef RUNNER_AUDIO_RECORDER_H_
#define RUNNER_AUDIO_RECORDER_H_

#include <flutter/flutter_view_controller.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include <atomic>
#include <memory>
#include <mutex>
#include <string>
#include <thread>

// Custom Speakr recording pipeline used while the live recorder is
// active. Captures the microphone (WASAPI shared-mode) and the system
// output (WASAPI loopback), mixes them with per-source live-mutable
// enable flags, and encodes the mixdown to AAC inside an .m4a container
// via Media Foundation's Sink Writer.
//
// One instance is constructed by `FlutterWindow` after the engine boots
// (see windows/runner/flutter_window.cpp) and lives for the process
// lifetime. The method channel `speakr.audio/recorder` is the Dart-side
// counterpart, used by `NativeLiveAudioRecorder`.
class SpeakrAudioRecorder {
 public:
  explicit SpeakrAudioRecorder(flutter::FlutterEngine* engine);
  ~SpeakrAudioRecorder();

  SpeakrAudioRecorder(const SpeakrAudioRecorder&) = delete;
  SpeakrAudioRecorder& operator=(const SpeakrAudioRecorder&) = delete;

 private:
  using MethodResult =
      flutter::MethodResult<flutter::EncodableValue>;
  using MethodCall = flutter::MethodCall<flutter::EncodableValue>;

  void HandleMethodCall(const MethodCall& call,
                        std::unique_ptr<MethodResult> result);

  bool Start(const std::string& path, bool micEnabled, bool systemEnabled,
             std::string* outError);
  std::string Stop();
  void DisposeRecorder();

  // The worker entry point. Owns COM + MF init, the two WASAPI capture
  // clients, and the MF sink writer.
  void RunWorker();

  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
      channel_;

  // Lifecycle.
  std::thread worker_;
  std::atomic<bool> running_{false};
  std::atomic<bool> stop_requested_{false};

  // Source enables — flipped live from any thread.
  std::atomic<bool> mic_enabled_{true};
  std::atomic<bool> system_enabled_{false};

  // Pause flag — when true, the worker still pumps WASAPI buffers (so
  // hardware doesn't underrun) but writes nothing to the sink writer.
  std::atomic<bool> paused_{false};

  // Configuration for the active session. Captured at Start() time;
  // read by the worker only after `running_` flips true.
  std::string output_path_;

  // Error message accumulated by the worker; surfaced via the next
  // Stop() / on the channel.
  std::mutex error_mu_;
  std::string last_error_;

  // Signalled when the worker has finished setup so Start() knows
  // whether the pipeline came up successfully.
  HANDLE setup_done_event_ = nullptr;
  std::atomic<bool> setup_ok_{false};
};

#endif  // RUNNER_AUDIO_RECORDER_H_
