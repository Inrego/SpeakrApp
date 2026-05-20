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
// output (WASAPI loopback, all-system or per-process), mixes them with
// per-source live-mutable enable flags, and encodes the mixdown to AAC
// inside an .m4a container via Media Foundation's Sink Writer.
//
// Per-process system audio capture uses `ActivateAudioInterfaceAsync`
// with `AUDIOCLIENT_ACTIVATION_TYPE_PROCESS_LOOPBACK` +
// `PROCESS_LOOPBACK_MODE_INCLUDE_TARGET_PROCESS_TREE`, which requires
// Windows build 20348 or newer (Server 2022, Windows 11). On older
// Windows the recorder reports `supportsProcessLoopback = false` so
// the UI hides the per-process option.
//
// One instance is constructed by `FlutterWindow` after the engine boots
// (see windows/runner/flutter_window.cpp) and lives for the process
// lifetime. The method channel `speakr.audio/recorder` is the Dart-side
// counterpart, used by `NativeLiveAudioRecorder`.
class SpeakrAudioRecorder {
 public:
  // Identifies which loopback flavor a `CaptureSource` represents. The
  // worker uses this when deciding whether the active loopback source
  // matches the requested target mode.
  enum class SystemMode : int {
    kOff = 0,
    kAllSystem = 1,
    kProcessOnly = 2,
  };

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

  bool Start(const std::string& path, bool micEnabled, SystemMode systemMode,
             DWORD processLoopbackPid, std::string* outError);
  std::string Stop(std::string* out_error = nullptr);
  void DisposeRecorder();

  // The worker entry point. Owns COM + MF init, the two WASAPI capture
  // clients, and the MF sink writer.
  void RunWorker();

  // True iff this Windows build supports the
  // `AUDIOCLIENT_ACTIVATION_TYPE_PROCESS_LOOPBACK` activation type
  // (build ≥ 20348). Cached at first query.
  bool SupportsProcessLoopback();

  // Enumerate currently-running processes that match an allowlist
  // entry. Used by the auto-record coordinator to pick a target PID
  // for process-loopback activation. The `kind` argument matches the
  // Dart-side `AllowlistKind` enum: "exeBasename" (case-insensitive
  // match on the exe filename) or "packagedPrefix" (prefix match on
  // the package family).
  std::vector<int> FindProcessPids(const std::string& kind,
                                   const std::string& matchKey,
                                   const std::string& exePath);

  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
      channel_;

  // Latest captured audio level in [0, 1], updated by the worker on every
  // mixed chunk and read by Dart via the `getLevel` MethodChannel call.
  // We can't push from the worker because EventSink::Success must run on
  // the platform thread; Dart polls at its own cadence (~20 Hz) instead.
  // Stored as raw bits so we don't depend on lock-free `atomic<double>`,
  // which isn't guaranteed pre-C++20.
  std::atomic<uint64_t> last_level_bits_{0};

  // Lifecycle.
  std::thread worker_;
  std::atomic<bool> running_{false};
  std::atomic<bool> stop_requested_{false};

  // Source enables — flipped live from any thread.
  std::atomic<bool> mic_enabled_{true};

  // Tri-state system mode (off / all-system loopback / process loopback).
  // The channel handler stores the new target here and bumps
  // `sys_mode_dirty_`; the worker observes both atomics between drain
  // iterations and re-opens the loopback `CaptureSource` when they
  // disagree with the currently-active source. Mutating the source
  // itself from any thread other than the worker would race with the
  // active `CaptureSource::Drain()`.
  std::atomic<int> sys_mode_target_{static_cast<int>(SystemMode::kOff)};
  std::atomic<DWORD> sys_pid_target_{0};
  std::atomic<bool> sys_mode_dirty_{false};

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

  // Cached result of the Windows build-number probe used by
  // `SupportsProcessLoopback`. 0 = uncomputed, 1 = no, 2 = yes.
  std::atomic<int> process_loopback_supported_{0};
};

#endif  // RUNNER_AUDIO_RECORDER_H_
