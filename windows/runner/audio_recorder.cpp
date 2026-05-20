#include "audio_recorder.h"

#include <Audioclient.h>
#include <Avrt.h>
#include <Mfapi.h>
#include <Mferror.h>
#include <Mfidl.h>
#include <Mfreadwrite.h>
#include <Mmdeviceapi.h>
#include <mmreg.h>
#include <ks.h>
#include <ksmedia.h>
#include <objbase.h>
#include <Psapi.h>
#include <appmodel.h>
#include <wrl/client.h>
#include <wrl/implements.h>

#include <algorithm>
#include <cmath>
#include <cstdio>
#include <cstring>
#include <vector>

// The process-loopback activation parameters were added in Windows SDK
// 10.0.20348. To stay compatible with older SDKs the runner is built
// against, declare the symbols inline rather than pulling in
// `AudioClientActivationParams.h`. The structs are stable Windows ABI;
// runtime support is gated by `SupportsProcessLoopback()` below.
#ifndef VIRTUAL_AUDIO_DEVICE_PROCESS_LOOPBACK
#define VIRTUAL_AUDIO_DEVICE_PROCESS_LOOPBACK \
  L"VAD\\Process_Loopback"
#endif

#ifndef SPEAKR_HAS_PROCESS_LOOPBACK_PARAMS
typedef enum SPEAKR_AUDIOCLIENT_ACTIVATION_TYPE {
  SPEAKR_AUDIOCLIENT_ACTIVATION_TYPE_DEFAULT = 0,
  SPEAKR_AUDIOCLIENT_ACTIVATION_TYPE_PROCESS_LOOPBACK = 1,
} SPEAKR_AUDIOCLIENT_ACTIVATION_TYPE;

typedef enum SPEAKR_PROCESS_LOOPBACK_MODE {
  SPEAKR_PROCESS_LOOPBACK_MODE_INCLUDE_TARGET_PROCESS_TREE = 0,
  SPEAKR_PROCESS_LOOPBACK_MODE_EXCLUDE_TARGET_PROCESS_TREE = 1,
} SPEAKR_PROCESS_LOOPBACK_MODE;

typedef struct SPEAKR_AUDIOCLIENT_PROCESS_LOOPBACK_PARAMS {
  DWORD TargetProcessId;
  SPEAKR_PROCESS_LOOPBACK_MODE ProcessLoopbackMode;
} SPEAKR_AUDIOCLIENT_PROCESS_LOOPBACK_PARAMS;

typedef struct SPEAKR_AUDIOCLIENT_ACTIVATION_PARAMS {
  SPEAKR_AUDIOCLIENT_ACTIVATION_TYPE ActivationType;
  union {
    SPEAKR_AUDIOCLIENT_PROCESS_LOOPBACK_PARAMS ProcessLoopbackParams;
  };
} SPEAKR_AUDIOCLIENT_ACTIVATION_PARAMS;
#endif

using flutter::EncodableMap;
using flutter::EncodableValue;
using flutter::MethodCall;
using flutter::MethodResult;
using flutter::StandardMethodCodec;

namespace {

constexpr UINT32 kTargetSampleRate = 48000;
constexpr UINT32 kTargetChannels = 2;
constexpr UINT32 kTargetBitsPerSample = 16;
constexpr UINT32 kAacBitsPerSecond = 16000;  // 128 kbps
constexpr LONGLONG kHnsPerSecond = 10000000;

// Reference-time per "buffer". 200 000 hns = 20 ms — well above the
// minimum WASAPI buffer and short enough that loopback latency feels
// instantaneous when toggling sources.
constexpr REFERENCE_TIME kBufferDuration = 200000;

template <typename T>
void SafeRelease(T** pp) {
  if (pp && *pp) {
    (*pp)->Release();
    *pp = nullptr;
  }
}

std::wstring Utf8ToUtf16(const std::string& s) {
  if (s.empty()) return {};
  int len = MultiByteToWideChar(CP_UTF8, 0, s.data(), (int)s.size(),
                                nullptr, 0);
  std::wstring w(len, L'\0');
  MultiByteToWideChar(CP_UTF8, 0, s.data(), (int)s.size(), w.data(), len);
  return w;
}

// Convert a WASAPI buffer (any common format) into interleaved stereo
// float at the source rate. Channel-down-mix is naive (drop extras),
// up-mix is mono→both channels.
std::vector<float> ConvertToStereoFloat(const BYTE* data,
                                        UINT32 frame_count,
                                        const WAVEFORMATEX* fmt) {
  std::vector<float> out;
  if (frame_count == 0) return out;
  out.resize(frame_count * 2);
  const UINT32 src_channels = fmt->nChannels;
  const WAVEFORMATEXTENSIBLE* ext =
      (fmt->wFormatTag == WAVE_FORMAT_EXTENSIBLE)
          ? reinterpret_cast<const WAVEFORMATEXTENSIBLE*>(fmt)
          : nullptr;
  const bool is_float =
      (fmt->wFormatTag == WAVE_FORMAT_IEEE_FLOAT) ||
      (ext && ext->SubFormat == KSDATAFORMAT_SUBTYPE_IEEE_FLOAT);
  const bool is_pcm = !is_float;

  for (UINT32 i = 0; i < frame_count; ++i) {
    float left = 0.0f, right = 0.0f;
    if (is_float) {
      const float* src = reinterpret_cast<const float*>(data);
      left = src[i * src_channels + 0];
      right =
          src_channels > 1 ? src[i * src_channels + 1] : left;
    } else if (is_pcm && fmt->wBitsPerSample == 16) {
      const int16_t* src = reinterpret_cast<const int16_t*>(data);
      left = src[i * src_channels + 0] / 32768.0f;
      right = src_channels > 1
                  ? src[i * src_channels + 1] / 32768.0f
                  : left;
    } else if (is_pcm && fmt->wBitsPerSample == 32) {
      const int32_t* src = reinterpret_cast<const int32_t*>(data);
      left = src[i * src_channels + 0] / 2147483648.0f;
      right = src_channels > 1
                  ? src[i * src_channels + 1] / 2147483648.0f
                  : left;
    }
    out[i * 2 + 0] = left;
    out[i * 2 + 1] = right;
  }
  return out;
}

// Pragmatic linear resampler from arbitrary source rate to 48 kHz.
// Per-call state preserves a half-sample of carry-over so we don't
// click at chunk boundaries. Good enough for voice/system audio at the
// typical 48 kHz Windows mix rate (in which case it's a passthrough).
struct StereoResampler {
  UINT32 src_rate = kTargetSampleRate;
  double phase = 0.0;
  float last_l = 0.0f, last_r = 0.0f;
  bool primed = false;

  std::vector<float> Process(const std::vector<float>& in) {
    if (src_rate == kTargetSampleRate) {
      if (!in.empty()) {
        primed = true;
        last_l = in[in.size() - 2];
        last_r = in[in.size() - 1];
      }
      return in;
    }
    std::vector<float> out;
    const size_t in_frames = in.size() / 2;
    if (in_frames == 0) return out;
    const double ratio =
        static_cast<double>(src_rate) / kTargetSampleRate;
    auto at = [&](double frac) {
      if (frac < 0) return std::pair<float, float>{last_l, last_r};
      const size_t i = static_cast<size_t>(frac);
      const double f = frac - i;
      auto l0 = i < in_frames ? in[i * 2 + 0] : in[(in_frames - 1) * 2 + 0];
      auto r0 = i < in_frames ? in[i * 2 + 1] : in[(in_frames - 1) * 2 + 1];
      auto l1 = (i + 1) < in_frames ? in[(i + 1) * 2 + 0] : l0;
      auto r1 = (i + 1) < in_frames ? in[(i + 1) * 2 + 1] : r0;
      return std::pair<float, float>{
          l0 + (l1 - l0) * static_cast<float>(f),
          r0 + (r1 - r0) * static_cast<float>(f)};
    };
    while (phase < static_cast<double>(in_frames)) {
      auto [l, r] = at(phase);
      out.push_back(l);
      out.push_back(r);
      phase += ratio;
    }
    phase -= in_frames;
    last_l = in[(in_frames - 1) * 2 + 0];
    last_r = in[(in_frames - 1) * 2 + 1];
    primed = true;
    return out;
  }
};

// Synchronous completion handler for `ActivateAudioInterfaceAsync`.
// The Windows API is fire-and-forget; we wait on a manual-reset event
// so the worker can use it like a synchronous call.
struct ActivateCompletionHandler
    : public Microsoft::WRL::RuntimeClass<
          Microsoft::WRL::RuntimeClassFlags<Microsoft::WRL::ClassicCom>,
          IActivateAudioInterfaceCompletionHandler> {
  HANDLE done = INVALID_HANDLE_VALUE;
  HRESULT activate_hr = E_PENDING;
  IUnknown* activated = nullptr;

  ActivateCompletionHandler() {
    done = CreateEventW(nullptr, TRUE, FALSE, nullptr);
  }

  ~ActivateCompletionHandler() {
    if (done && done != INVALID_HANDLE_VALUE) CloseHandle(done);
    SafeRelease(&activated);
  }

  STDMETHOD(ActivateCompleted)(
      IActivateAudioInterfaceAsyncOperation* op) override {
    HRESULT activate_status = E_FAIL;
    HRESULT op_hr = op->GetActivateResult(&activate_status, &activated);
    activate_hr = SUCCEEDED(op_hr) ? activate_status : op_hr;
    SetEvent(done);
    return S_OK;
  }
};

// One WASAPI capture source — wraps device + audio client + capture
// client + the resampler that brings it to the common mix rate.
struct CaptureSource {
  IMMDevice* device = nullptr;
  IAudioClient* audio_client = nullptr;
  IAudioCaptureClient* capture_client = nullptr;
  HANDLE event = nullptr;
  WAVEFORMATEX* fmt = nullptr;
  StereoResampler resampler;
  // Pending stereo-float samples at target rate, waiting to be mixed.
  std::vector<float> pcm;
  bool loopback = false;
  bool started = false;
  // 0 = all-system loopback; non-zero = root PID for process loopback.
  DWORD process_pid = 0;

  ~CaptureSource() {
    if (audio_client && started) audio_client->Stop();
    SafeRelease(&capture_client);
    SafeRelease(&audio_client);
    SafeRelease(&device);
    if (event) CloseHandle(event);
    if (fmt) CoTaskMemFree(fmt);
  }

  // Open the mic or default-loopback source via the standard
  // `IMMDevice::Activate` path.
  HRESULT Open(IMMDeviceEnumerator* enumer, EDataFlow flow, bool is_loopback) {
    loopback = is_loopback;
    process_pid = 0;
    HRESULT hr = enumer->GetDefaultAudioEndpoint(flow, eMultimedia, &device);
    if (FAILED(hr)) return hr;
    hr = device->Activate(__uuidof(IAudioClient), CLSCTX_ALL, nullptr,
                          reinterpret_cast<void**>(&audio_client));
    if (FAILED(hr)) return hr;
    hr = audio_client->GetMixFormat(&fmt);
    if (FAILED(hr)) return hr;
    DWORD flags = AUDCLNT_STREAMFLAGS_EVENTCALLBACK;
    if (is_loopback) flags |= AUDCLNT_STREAMFLAGS_LOOPBACK;
    // Loopback never delivers buffer-ready events on its own — we have
    // to poll. For mic, event-driven works. To keep one code path, use
    // a timer-style poll for both at the buffer rate.
    if (is_loopback) {
      flags &= ~AUDCLNT_STREAMFLAGS_EVENTCALLBACK;
    }
    hr = audio_client->Initialize(AUDCLNT_SHAREMODE_SHARED, flags,
                                  kBufferDuration, 0, fmt, nullptr);
    if (FAILED(hr)) return hr;
    if (!is_loopback) {
      event = CreateEventW(nullptr, FALSE, FALSE, nullptr);
      if (!event) return HRESULT_FROM_WIN32(GetLastError());
      hr = audio_client->SetEventHandle(event);
      if (FAILED(hr)) return hr;
    }
    hr = audio_client->GetService(__uuidof(IAudioCaptureClient),
                                  reinterpret_cast<void**>(&capture_client));
    if (FAILED(hr)) return hr;
    resampler.src_rate = fmt->nSamplesPerSec;
    return S_OK;
  }

  // Open a process-loopback source via `ActivateAudioInterfaceAsync`
  // against `VIRTUAL_AUDIO_DEVICE_PROCESS_LOOPBACK`, scoped to the
  // process tree rooted at `pid`. The format is fixed by the API
  // (48 kHz 16-bit stereo PCM); we still run the resampler to keep
  // a single code path with the mic source.
  HRESULT OpenProcessLoopback(DWORD pid) {
    loopback = true;
    process_pid = pid;

    SPEAKR_AUDIOCLIENT_ACTIVATION_PARAMS params = {};
    params.ActivationType =
        SPEAKR_AUDIOCLIENT_ACTIVATION_TYPE_PROCESS_LOOPBACK;
    params.ProcessLoopbackParams.TargetProcessId = pid;
    params.ProcessLoopbackParams.ProcessLoopbackMode =
        SPEAKR_PROCESS_LOOPBACK_MODE_INCLUDE_TARGET_PROCESS_TREE;

    PROPVARIANT prop;
    PropVariantInit(&prop);
    prop.vt = VT_BLOB;
    prop.blob.cbSize = sizeof(params);
    prop.blob.pBlobData = reinterpret_cast<BYTE*>(&params);

    Microsoft::WRL::ComPtr<ActivateCompletionHandler> handler =
        Microsoft::WRL::Make<ActivateCompletionHandler>();
    if (!handler || handler->done == INVALID_HANDLE_VALUE) {
      return E_OUTOFMEMORY;
    }

    IActivateAudioInterfaceAsyncOperation* op = nullptr;
    HRESULT hr = ActivateAudioInterfaceAsync(
        VIRTUAL_AUDIO_DEVICE_PROCESS_LOOPBACK,
        __uuidof(IAudioClient),
        &prop,
        handler.Get(),
        &op);
    if (FAILED(hr)) {
      SafeRelease(&op);
      return hr;
    }
    // Wait up to 2 s for activation. WASAPI usually completes in well
    // under 100 ms; the timeout is just so we don't deadlock the
    // worker if Windows misbehaves.
    DWORD wait = WaitForSingleObject(handler->done, 2000);
    SafeRelease(&op);
    if (wait != WAIT_OBJECT_0) return HRESULT_FROM_WIN32(ERROR_TIMEOUT);
    if (FAILED(handler->activate_hr)) return handler->activate_hr;
    hr = handler->activated->QueryInterface(
        __uuidof(IAudioClient),
        reinterpret_cast<void**>(&audio_client));
    if (FAILED(hr)) return hr;

    // The process-loopback endpoint requires a fixed 48 kHz / stereo /
    // 16-bit PCM format — `GetMixFormat` doesn't apply here.
    fmt = static_cast<WAVEFORMATEX*>(CoTaskMemAlloc(sizeof(WAVEFORMATEX)));
    if (!fmt) return E_OUTOFMEMORY;
    fmt->wFormatTag = WAVE_FORMAT_PCM;
    fmt->nChannels = 2;
    fmt->nSamplesPerSec = 48000;
    fmt->wBitsPerSample = 16;
    fmt->nBlockAlign = static_cast<WORD>(fmt->nChannels *
                                         fmt->wBitsPerSample / 8);
    fmt->nAvgBytesPerSec = fmt->nSamplesPerSec * fmt->nBlockAlign;
    fmt->cbSize = 0;

    // EVENTCALLBACK | LOOPBACK as required by the process-loopback API.
    DWORD flags = AUDCLNT_STREAMFLAGS_EVENTCALLBACK |
                  AUDCLNT_STREAMFLAGS_LOOPBACK;
    hr = audio_client->Initialize(AUDCLNT_SHAREMODE_SHARED, flags,
                                  kBufferDuration, 0, fmt, nullptr);
    if (FAILED(hr)) return hr;
    event = CreateEventW(nullptr, FALSE, FALSE, nullptr);
    if (!event) return HRESULT_FROM_WIN32(GetLastError());
    hr = audio_client->SetEventHandle(event);
    if (FAILED(hr)) return hr;
    hr = audio_client->GetService(__uuidof(IAudioCaptureClient),
                                  reinterpret_cast<void**>(&capture_client));
    if (FAILED(hr)) return hr;
    resampler.src_rate = fmt->nSamplesPerSec;
    return S_OK;
  }

  HRESULT Start() {
    HRESULT hr = audio_client->Start();
    if (SUCCEEDED(hr)) started = true;
    return hr;
  }

  // Drain the WASAPI capture client into `pcm`. If `gate_to_silence`
  // is true, the data is replaced with zeros (used when the user has
  // toggled this source off).
  HRESULT Drain(bool gate_to_silence) {
    UINT32 packet = 0;
    HRESULT hr = capture_client->GetNextPacketSize(&packet);
    if (FAILED(hr)) return hr;
    while (packet > 0) {
      BYTE* data = nullptr;
      UINT32 frames = 0;
      DWORD flags_out = 0;
      hr = capture_client->GetBuffer(&data, &frames, &flags_out, nullptr,
                                     nullptr);
      if (FAILED(hr)) return hr;
      auto stereo = ConvertToStereoFloat(data, frames, fmt);
      capture_client->ReleaseBuffer(frames);
      auto resampled = resampler.Process(stereo);
      if (gate_to_silence) {
        std::fill(resampled.begin(), resampled.end(), 0.0f);
      }
      pcm.insert(pcm.end(), resampled.begin(), resampled.end());
      hr = capture_client->GetNextPacketSize(&packet);
      if (FAILED(hr)) return hr;
    }
    return S_OK;
  }

  // Append synthesized silence covering `frames_at_target_rate` frames.
  // Used when the source can't keep up so the mixer doesn't starve.
  void AppendSilence(UINT32 frames_at_target_rate) {
    pcm.insert(pcm.end(),
               static_cast<size_t>(frames_at_target_rate) * 2, 0.0f);
  }
};

}  // namespace

// ---------------------------------------------------------------------------
//                           SpeakrAudioRecorder
// ---------------------------------------------------------------------------

namespace {

// Helpers to pack/unpack a double into the `last_level_bits_` atomic. We
// avoid `atomic<double>` because lock-freedom for it isn't guaranteed on
// older toolchains; the worker writes ~50× per second so contention is
// not a concern.
uint64_t DoubleToBits(double v) {
  uint64_t bits = 0;
  std::memcpy(&bits, &v, sizeof(bits));
  return bits;
}

double BitsToDouble(uint64_t bits) {
  double v = 0.0;
  std::memcpy(&v, &bits, sizeof(v));
  return v;
}

}  // namespace

SpeakrAudioRecorder::SpeakrAudioRecorder(flutter::FlutterEngine* engine) {
  channel_ = std::make_unique<flutter::MethodChannel<EncodableValue>>(
      engine->messenger(), "speakr.audio/recorder",
      &StandardMethodCodec::GetInstance());
  channel_->SetMethodCallHandler(
      [this](const MethodCall& call,
             std::unique_ptr<MethodResult> result) {
        HandleMethodCall(call, std::move(result));
      });
}

SpeakrAudioRecorder::~SpeakrAudioRecorder() {
  DisposeRecorder();
}

bool SpeakrAudioRecorder::SupportsProcessLoopback() {
  int cached = process_loopback_supported_.load();
  if (cached != 0) return cached == 2;
  // Build-number probe via RtlGetVersion — the public Get*Version
  // wrappers report 10.0 / 6.2 even on Windows 11, so we read the real
  // build number from ntdll. PROCESS_LOOPBACK was added in build 20348
  // (Server 2022 / Windows 11).
  bool supported = false;
  HMODULE ntdll = ::GetModuleHandleW(L"ntdll.dll");
  if (ntdll) {
    using RtlGetVersionFn = LONG(WINAPI*)(PRTL_OSVERSIONINFOW);
    auto fn = reinterpret_cast<RtlGetVersionFn>(
        ::GetProcAddress(ntdll, "RtlGetVersion"));
    if (fn) {
      RTL_OSVERSIONINFOW info = {};
      info.dwOSVersionInfoSize = sizeof(info);
      if (fn(&info) == 0 /* STATUS_SUCCESS */) {
        supported = info.dwBuildNumber >= 20348;
      }
    }
  }
  process_loopback_supported_.store(supported ? 2 : 1);
  return supported;
}

namespace {

// Case-insensitive ASCII compare. Sufficient for exe basenames and
// package-family prefixes (both restricted to ASCII in practice).
bool IEqual(const std::wstring& a, const std::wstring& b) {
  if (a.size() != b.size()) return false;
  for (size_t i = 0; i < a.size(); ++i) {
    wchar_t ca = a[i], cb = b[i];
    if (ca >= L'A' && ca <= L'Z') ca = ca - L'A' + L'a';
    if (cb >= L'A' && cb <= L'Z') cb = cb - L'A' + L'a';
    if (ca != cb) return false;
  }
  return true;
}

bool IStartsWith(const std::wstring& a, const std::wstring& prefix) {
  if (a.size() < prefix.size()) return false;
  return IEqual(a.substr(0, prefix.size()), prefix);
}

std::wstring Utf8ToWide(const std::string& s) {
  if (s.empty()) return L"";
  int len = ::MultiByteToWideChar(CP_UTF8, 0, s.data(),
                                  static_cast<int>(s.size()), nullptr, 0);
  std::wstring w(len, L'\0');
  ::MultiByteToWideChar(CP_UTF8, 0, s.data(), static_cast<int>(s.size()),
                        w.data(), len);
  return w;
}

}  // namespace

std::vector<int> SpeakrAudioRecorder::FindProcessPids(
    const std::string& kind, const std::string& matchKey,
    const std::string& /*exePath*/) {
  std::vector<int> result;
  if (!SupportsProcessLoopback()) return result;
  const std::wstring key = Utf8ToWide(matchKey);
  const bool packaged = (kind == "packagedPrefix");

  DWORD pids[2048];
  DWORD bytes = 0;
  if (!EnumProcesses(pids, sizeof(pids), &bytes)) return result;
  const DWORD count = bytes / sizeof(DWORD);
  for (DWORD i = 0; i < count; ++i) {
    DWORD pid = pids[i];
    if (pid == 0 || pid == ::GetCurrentProcessId()) continue;
    HANDLE h = ::OpenProcess(
        PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid);
    if (!h) continue;
    if (packaged) {
      // Compare package family prefix via the process AUMID, when set.
      UINT32 len = 0;
      LONG rc = ::GetApplicationUserModelId(h, &len, nullptr);
      if (rc == ERROR_INSUFFICIENT_BUFFER && len > 0) {
        std::wstring aumid(len, L'\0');
        rc = ::GetApplicationUserModelId(h, &len, aumid.data());
        if (rc == ERROR_SUCCESS) {
          if (!aumid.empty() && aumid.back() == L'\0') aumid.pop_back();
          // AUMID looks like "MSTeams_8wekyb3d8bbwe!Teams". The match key
          // is the package family ("MSTeams_8wekyb3d8bbwe") or a prefix
          // of it ("MSTeams").
          if (IStartsWith(aumid, key)) {
            result.push_back(static_cast<int>(pid));
          }
        }
      }
    } else {
      // Match the exe basename, case-insensitively.
      wchar_t path[MAX_PATH];
      DWORD path_len = MAX_PATH;
      if (::QueryFullProcessImageNameW(h, 0, path, &path_len)) {
        std::wstring full(path, path_len);
        size_t slash = full.find_last_of(L"\\/");
        std::wstring base =
            slash == std::wstring::npos ? full : full.substr(slash + 1);
        if (IEqual(base, key)) {
          result.push_back(static_cast<int>(pid));
        }
      }
    }
    ::CloseHandle(h);
  }
  return result;
}

void SpeakrAudioRecorder::DisposeRecorder() {
  if (running_.load()) {
    stop_requested_.store(true);
    if (worker_.joinable()) worker_.join();
    running_.store(false);
  }
  if (setup_done_event_) {
    CloseHandle(setup_done_event_);
    setup_done_event_ = nullptr;
  }
}

void SpeakrAudioRecorder::HandleMethodCall(
    const MethodCall& call, std::unique_ptr<MethodResult> result) {
  const std::string& name = call.method_name();
  if (name == "supportsSystemAudio") {
    result->Success(EncodableValue(true));
    return;
  }
  if (name == "supportsProcessLoopback") {
    result->Success(EncodableValue(SupportsProcessLoopback()));
    return;
  }
  if (name == "requestSystemPermission") {
    // Windows doesn't need a per-session consent for WASAPI loopback.
    result->Success(EncodableValue(true));
    return;
  }
  if (name == "findProcessPids") {
    const auto* args = std::get_if<EncodableMap>(call.arguments());
    std::string kind, matchKey, exePath;
    if (args) {
      for (const auto& kv : *args) {
        const auto* key = std::get_if<std::string>(&kv.first);
        if (!key) continue;
        if (*key == "kind") {
          if (const auto* v = std::get_if<std::string>(&kv.second)) kind = *v;
        } else if (*key == "matchKey") {
          if (const auto* v = std::get_if<std::string>(&kv.second))
            matchKey = *v;
        } else if (*key == "exePath") {
          if (const auto* v = std::get_if<std::string>(&kv.second))
            exePath = *v;
        }
      }
    }
    auto pids = FindProcessPids(kind, matchKey, exePath);
    flutter::EncodableList out;
    out.reserve(pids.size());
    for (int p : pids) out.push_back(EncodableValue(p));
    result->Success(EncodableValue(out));
    return;
  }
  if (name == "isRecording") {
    result->Success(EncodableValue(running_.load() && !stop_requested_.load()));
    return;
  }
  if (name == "getLevel") {
    // Read whatever the worker last stored. While not running, this is
    // 0 (set in Stop / DisposeRecorder / on worker exit), which is what
    // the meter wants too.
    const double level = BitsToDouble(last_level_bits_.load());
    result->Success(EncodableValue(level));
    return;
  }
  if (name == "start") {
    const auto* args = std::get_if<EncodableMap>(call.arguments());
    if (!args) {
      result->Error("bad_args", "start expected a map");
      return;
    }
    std::string path;
    bool mic = true;
    SystemMode mode = SystemMode::kOff;
    DWORD pid = 0;
    for (const auto& kv : *args) {
      const auto* key = std::get_if<std::string>(&kv.first);
      if (!key) continue;
      if (*key == "path") {
        if (const auto* v = std::get_if<std::string>(&kv.second)) path = *v;
      } else if (*key == "micEnabled") {
        if (const auto* v = std::get_if<bool>(&kv.second)) mic = *v;
      } else if (*key == "systemMode") {
        if (const auto* v = std::get_if<std::string>(&kv.second)) {
          if (*v == "all") mode = SystemMode::kAllSystem;
          else if (*v == "process") mode = SystemMode::kProcessOnly;
          else mode = SystemMode::kOff;
        }
      } else if (*key == "processLoopbackPid") {
        if (const auto* v = std::get_if<int32_t>(&kv.second)) {
          pid = static_cast<DWORD>(*v);
        } else if (const auto* v64 = std::get_if<int64_t>(&kv.second)) {
          pid = static_cast<DWORD>(*v64);
        }
      }
    }
    std::string err;
    if (!Start(path, mic, mode, pid, &err)) {
      result->Error("start_failed", err);
      return;
    }
    result->Success();
    return;
  }
  if (name == "setMicEnabled") {
    const auto* args = std::get_if<EncodableMap>(call.arguments());
    bool v = true;
    if (args) {
      for (const auto& kv : *args) {
        if (const auto* key = std::get_if<std::string>(&kv.first)) {
          if (*key == "enabled") {
            if (const auto* b = std::get_if<bool>(&kv.second)) v = *b;
          }
        }
      }
    }
    mic_enabled_.store(v);
    result->Success();
    return;
  }
  if (name == "setSystemMode") {
    const auto* args = std::get_if<EncodableMap>(call.arguments());
    SystemMode mode = SystemMode::kOff;
    DWORD pid = 0;
    if (args) {
      for (const auto& kv : *args) {
        const auto* key = std::get_if<std::string>(&kv.first);
        if (!key) continue;
        if (*key == "mode") {
          if (const auto* v = std::get_if<std::string>(&kv.second)) {
            if (*v == "all") mode = SystemMode::kAllSystem;
            else if (*v == "process") mode = SystemMode::kProcessOnly;
            else mode = SystemMode::kOff;
          }
        } else if (*key == "processLoopbackPid") {
          if (const auto* v = std::get_if<int32_t>(&kv.second)) {
            pid = static_cast<DWORD>(*v);
          } else if (const auto* v64 = std::get_if<int64_t>(&kv.second)) {
            pid = static_cast<DWORD>(*v64);
          }
        }
      }
    }
    sys_mode_target_.store(static_cast<int>(mode));
    sys_pid_target_.store(pid);
    sys_mode_dirty_.store(true);
    result->Success();
    return;
  }
  if (name == "pause") {
    paused_.store(true);
    result->Success();
    return;
  }
  if (name == "resume") {
    paused_.store(false);
    result->Success();
    return;
  }
  if (name == "stop") {
    std::string err;
    std::string path = Stop(&err);
    if (!err.empty()) {
      result->Error("stop_failed", err);
    } else if (path.empty()) {
      result->Success();
    } else {
      result->Success(EncodableValue(path));
    }
    return;
  }
  if (name == "dispose") {
    DisposeRecorder();
    result->Success();
    return;
  }
  result->NotImplemented();
}

bool SpeakrAudioRecorder::Start(const std::string& path, bool mic_enabled,
                                SystemMode system_mode,
                                DWORD process_loopback_pid,
                                std::string* out_error) {
  if (running_.load()) {
    if (out_error) *out_error = "Recorder is already running.";
    return false;
  }
  if (path.empty()) {
    if (out_error) *out_error = "Output path is empty.";
    return false;
  }
  output_path_ = path;
  mic_enabled_.store(mic_enabled);
  sys_mode_target_.store(static_cast<int>(system_mode));
  sys_pid_target_.store(process_loopback_pid);
  sys_mode_dirty_.store(false);
  paused_.store(false);
  stop_requested_.store(false);
  setup_ok_.store(false);
  last_level_bits_.store(DoubleToBits(0.0));
  {
    std::lock_guard<std::mutex> lock(error_mu_);
    last_error_.clear();
  }
  if (setup_done_event_) CloseHandle(setup_done_event_);
  setup_done_event_ = CreateEventW(nullptr, TRUE, FALSE, nullptr);
  if (!setup_done_event_) {
    if (out_error) *out_error = "Failed to create setup event.";
    return false;
  }
  running_.store(true);
  worker_ = std::thread(&SpeakrAudioRecorder::RunWorker, this);
  // Wait up to 5 s for setup to complete so callers see a real error
  // immediately rather than silently failing inside the worker.
  WaitForSingleObject(setup_done_event_, 5000);
  if (!setup_ok_.load()) {
    stop_requested_.store(true);
    if (worker_.joinable()) worker_.join();
    running_.store(false);
    std::lock_guard<std::mutex> lock(error_mu_);
    if (out_error)
      *out_error = last_error_.empty() ? "Recorder failed to start."
                                       : last_error_;
    return false;
  }
  return true;
}

std::string SpeakrAudioRecorder::Stop(std::string* out_error) {
  if (!running_.load()) return {};
  stop_requested_.store(true);
  if (worker_.joinable()) worker_.join();
  running_.store(false);
  std::lock_guard<std::mutex> lock(error_mu_);
  if (!last_error_.empty()) {
    // Worker bailed mid-recording; the partial m4a is already deleted.
    if (out_error) *out_error = last_error_;
    return {};
  }
  return output_path_;
}

// ---------------------------------------------------------------------------
//                              Worker thread
// ---------------------------------------------------------------------------

void SpeakrAudioRecorder::RunWorker() {
  auto record_error = [&](const std::string& s) {
    std::lock_guard<std::mutex> lock(error_mu_);
    last_error_ = s;
  };

  HRESULT hr = CoInitializeEx(nullptr, COINIT_MULTITHREADED);
  bool co_init = SUCCEEDED(hr);
  hr = MFStartup(MF_VERSION);
  bool mf_init = SUCCEEDED(hr);
  if (!mf_init) {
    record_error("MFStartup failed.");
    SetEvent(setup_done_event_);
    if (co_init) CoUninitialize();
    return;
  }

  DWORD task_index = 0;
  HANDLE task = AvSetMmThreadCharacteristicsW(L"Audio", &task_index);

  // Open both capture sources up front. Even when the user starts with
  // system audio off, opening the loopback client now means flipping
  // the toggle on later is instantaneous.
  IMMDeviceEnumerator* enumer = nullptr;
  hr = CoCreateInstance(__uuidof(MMDeviceEnumerator), nullptr, CLSCTX_ALL,
                        __uuidof(IMMDeviceEnumerator),
                        reinterpret_cast<void**>(&enumer));
  if (FAILED(hr)) {
    record_error("MMDeviceEnumerator unavailable.");
    SetEvent(setup_done_event_);
    MFShutdown();
    if (task) AvRevertMmThreadCharacteristics(task);
    if (co_init) CoUninitialize();
    return;
  }

  CaptureSource mic_src;
  std::unique_ptr<CaptureSource> sys_src;
  hr = mic_src.Open(enumer, eCapture, /*is_loopback=*/false);
  if (FAILED(hr)) {
    record_error("Could not open microphone (HRESULT 0x" +
                 std::to_string(static_cast<unsigned>(hr)) + ").");
    SafeRelease(&enumer);
    SetEvent(setup_done_event_);
    MFShutdown();
    if (task) AvRevertMmThreadCharacteristics(task);
    if (co_init) CoUninitialize();
    return;
  }

  // Lambda to (re)build sys_src for the current target mode. Called
  // both during initial setup and any time `sys_mode_dirty_` flips.
  auto rebuild_sys_src = [&]() -> bool {
    sys_src.reset();
    SystemMode mode =
        static_cast<SystemMode>(sys_mode_target_.load());
    if (mode == SystemMode::kOff) {
      return false;
    }
    auto next = std::make_unique<CaptureSource>();
    HRESULT open_hr = E_FAIL;
    if (mode == SystemMode::kAllSystem) {
      open_hr = next->Open(enumer, eRender, /*is_loopback=*/true);
    } else {
      DWORD pid = sys_pid_target_.load();
      if (pid != 0) {
        open_hr = next->OpenProcessLoopback(pid);
      }
    }
    if (FAILED(open_hr)) {
#ifndef NDEBUG
      char dbg[128];
      snprintf(dbg, sizeof(dbg),
               "[speakr] sys_src open mode=%d hr=0x%08X\n",
               static_cast<int>(mode), static_cast<unsigned>(open_hr));
      OutputDebugStringA(dbg);
#endif
      return false;
    }
    HRESULT start_hr = next->Start();
    if (FAILED(start_hr)) {
      return false;
    }
    sys_src = std::move(next);
    return true;
  };

  bool have_system = rebuild_sys_src();
  // Keep `enumer` alive for the worker's lifetime so the mid-session
  // hot-swap path can reopen `sys_src` against `eRender` without a
  // fresh CoCreateInstance round-trip.

  // Configure MF sink writer for AAC m4a.
  IMFSinkWriter* writer = nullptr;
  DWORD stream_index = 0;
  IMFMediaType* out_type = nullptr;
  IMFMediaType* in_type = nullptr;
  std::wstring wpath = Utf8ToUtf16(output_path_);
  hr = MFCreateSinkWriterFromURL(wpath.c_str(), nullptr, nullptr, &writer);
  if (FAILED(hr)) {
    record_error("MFCreateSinkWriterFromURL failed (" + output_path_ + ").");
    SetEvent(setup_done_event_);
    MFShutdown();
    if (task) AvRevertMmThreadCharacteristics(task);
    if (co_init) CoUninitialize();
    return;
  }
  do {
    hr = MFCreateMediaType(&out_type);
    if (FAILED(hr)) break;
    out_type->SetGUID(MF_MT_MAJOR_TYPE, MFMediaType_Audio);
    out_type->SetGUID(MF_MT_SUBTYPE, MFAudioFormat_AAC);
    out_type->SetUINT32(MF_MT_AUDIO_BITS_PER_SAMPLE, 16);
    out_type->SetUINT32(MF_MT_AUDIO_SAMPLES_PER_SECOND, kTargetSampleRate);
    out_type->SetUINT32(MF_MT_AUDIO_NUM_CHANNELS, kTargetChannels);
    out_type->SetUINT32(MF_MT_AUDIO_AVG_BYTES_PER_SECOND, kAacBitsPerSecond);
    out_type->SetUINT32(MF_MT_AAC_AUDIO_PROFILE_LEVEL_INDICATION, 0x29);
    hr = writer->AddStream(out_type, &stream_index);
    if (FAILED(hr)) break;
    hr = MFCreateMediaType(&in_type);
    if (FAILED(hr)) break;
    in_type->SetGUID(MF_MT_MAJOR_TYPE, MFMediaType_Audio);
    in_type->SetGUID(MF_MT_SUBTYPE, MFAudioFormat_PCM);
    in_type->SetUINT32(MF_MT_AUDIO_BITS_PER_SAMPLE, kTargetBitsPerSample);
    in_type->SetUINT32(MF_MT_AUDIO_SAMPLES_PER_SECOND, kTargetSampleRate);
    in_type->SetUINT32(MF_MT_AUDIO_NUM_CHANNELS, kTargetChannels);
    in_type->SetUINT32(MF_MT_AUDIO_BLOCK_ALIGNMENT,
                       kTargetChannels * kTargetBitsPerSample / 8);
    in_type->SetUINT32(MF_MT_AUDIO_AVG_BYTES_PER_SECOND,
                       kTargetSampleRate * kTargetChannels *
                           kTargetBitsPerSample / 8);
    hr = writer->SetInputMediaType(stream_index, in_type, nullptr);
    if (FAILED(hr)) break;
    hr = writer->BeginWriting();
  } while (false);
  if (FAILED(hr)) {
    record_error("Sink writer setup failed.");
    SafeRelease(&out_type);
    SafeRelease(&in_type);
    SafeRelease(&writer);
    SetEvent(setup_done_event_);
    MFShutdown();
    if (task) AvRevertMmThreadCharacteristics(task);
    if (co_init) CoUninitialize();
    return;
  }
  SafeRelease(&out_type);
  SafeRelease(&in_type);

  hr = mic_src.Start();
  if (FAILED(hr)) {
    record_error("Mic IAudioClient::Start failed.");
    SafeRelease(&writer);
    SafeRelease(&enumer);
    SetEvent(setup_done_event_);
    MFShutdown();
    if (task) AvRevertMmThreadCharacteristics(task);
    if (co_init) CoUninitialize();
    return;
  }
  // `sys_src` (when active) was already Start()-ed by `rebuild_sys_src`.

  setup_ok_.store(true);
  SetEvent(setup_done_event_);

  // Mixer state: PTS tracked in 100ns units at the target sample rate.
  // We emit one 20 ms chunk per loop iteration so toggling sources
  // shows up in the file within a single chunk.
  constexpr UINT32 kChunkFrames = kTargetSampleRate / 50;  // 960
  const size_t kChunkSamples = kChunkFrames * kTargetChannels;
  std::vector<int16_t> out_pcm;
  out_pcm.resize(kChunkSamples);

  // Pre-allocate an MF sample buffer and reuse it each iteration.
  LONGLONG pts_hns = 0;
  uint64_t chunks_written = 0;

  // Sidecar buffer fed when `sys_src` is null (mic-only or between
  // hot-swap rebuilds). Kept structurally identical to the active
  // `sys_src` so the chunk-write loop below can read from a single
  // source without branching.
  std::vector<float> sys_silence_pcm;

  // Loop until stop_requested.
  while (!stop_requested_.load()) {
    // Hot-swap the loopback source if the channel handler bumped
    // sys_mode_dirty_. Runs on the worker thread (not the channel
    // thread) so it doesn't race with `sys_src->Drain()` below.
    if (sys_mode_dirty_.exchange(false)) {
      have_system = rebuild_sys_src();
      sys_silence_pcm.clear();
    }

    // Wait for mic event; on timeout still poll loopback.
    if (mic_src.event) {
      WaitForSingleObject(mic_src.event, 20);
    } else {
      Sleep(10);
    }

    // Drain mic.
    HRESULT dh = mic_src.Drain(/*gate_to_silence=*/!mic_enabled_.load());
    if (FAILED(dh)) {
      record_error("Mic drain failed.");
      break;
    }
    if (have_system && sys_src) {
      const size_t sys_before = sys_src->pcm.size();
      dh = sys_src->Drain(/*gate_to_silence=*/false);
      if (FAILED(dh)) {
        // Loopback can transiently fail; treat as silence and keep going.
        sys_src->AppendSilence(kChunkFrames);
      } else if (sys_src->pcm.size() == sys_before) {
        // WASAPI loopback returns no packets while nothing is playing,
        // rather than zero-filled silence buffers. Pad with our own
        // silence so the chunk-write condition below (which AND-s mic
        // and system queue sizes) can still fire — otherwise a silent
        // system stalls the whole pipeline and the recording ends with
        // zero chunks written.
        sys_src->AppendSilence(kChunkFrames);
      }
    } else {
      sys_silence_pcm.insert(
          sys_silence_pcm.end(),
          static_cast<size_t>(kChunkFrames) * kTargetChannels,
          0.0f);
    }

    auto& sys_pcm = (have_system && sys_src) ? sys_src->pcm : sys_silence_pcm;

    // Mix as many full chunks as both queues have ready.
    while (mic_src.pcm.size() >= kChunkSamples &&
           sys_pcm.size() >= kChunkSamples) {
      // Track each source's sum-of-squares separately so the meter
      // reflects whichever source is louder. RMS over the mix (m+s) has
      // a subtle bias: a constant mic noise floor dominates the result
      // so a quiet system signal never moves the dot. Taking the max of
      // per-source levels solves that — system music will register even
      // when the user isn't speaking.
      double mic_sum_sq = 0.0;
      double sys_sum_sq = 0.0;
      for (size_t i = 0; i < kChunkSamples; ++i) {
        float m = mic_src.pcm[i];
        float s = sys_pcm[i];
        float sum = m + s;
        if (sum > 1.0f) sum = 1.0f;
        if (sum < -1.0f) sum = -1.0f;
        out_pcm[i] = static_cast<int16_t>(sum * 32767.0f);
        mic_sum_sq += static_cast<double>(m) * static_cast<double>(m);
        sys_sum_sq += static_cast<double>(s) * static_cast<double>(s);
      }
      mic_src.pcm.erase(mic_src.pcm.begin(),
                        mic_src.pcm.begin() + kChunkSamples);
      sys_pcm.erase(sys_pcm.begin(), sys_pcm.begin() + kChunkSamples);

      // Buffer the latest meter sample in `last_level_bits_`; Dart polls
      // via `getLevel`. While paused, park the value at 0 so the
      // breathing dot collapses on the next poll.
      if (paused_.load()) {
        last_level_bits_.store(DoubleToBits(0.0));
        // Drop the chunk — don't advance pts. Effectively pauses the
        // timeline. (The Dart-side timer also pauses in this state.)
        continue;
      }
      const double mic_rms =
          std::sqrt(mic_sum_sq / static_cast<double>(kChunkSamples));
      const double sys_rms =
          std::sqrt(sys_sum_sq / static_cast<double>(kChunkSamples));
      // -55 dBFS → 0, -12 dBFS → 1. Picked so a quiet room sits at
      // floor, normal speech (~-30 dBFS RMS) reads ~0.58, a loud talker
      // (~-15 dBFS RMS) approaches the top.
      constexpr double kFloorDb = -55.0;
      constexpr double kCeilDb = -12.0;
      auto rms_to_level = [kFloorDb, kCeilDb](double r) -> double {
        if (r < 1e-6) return 0.0;
        const double db = 20.0 * std::log10(r);
        double v = (db - kFloorDb) / (kCeilDb - kFloorDb);
        if (v < 0.0) return 0.0;
        if (v > 1.0) return 1.0;
        return v;
      };
      const double mic_level = rms_to_level(mic_rms);
      const double sys_level = rms_to_level(sys_rms);
      const double level = std::max(mic_level, sys_level);
      last_level_bits_.store(DoubleToBits(level));
#ifndef NDEBUG
      // Periodic per-source breadcrumb so we can confirm via DebugView /
      // VS output whether loopback is delivering data. ~1 line per
      // second at 50 chunks/s.
      if ((chunks_written % 50u) == 0u) {
        char dbg[160];
        snprintf(dbg, sizeof(dbg),
                 "[speakr] level mic=%.3f (rms=%.4f) sys=%.3f (rms=%.4f) "
                 "have_system=%d sys_mode=%d sys_pid=%lu\n",
                 mic_level, mic_rms, sys_level, sys_rms,
                 have_system ? 1 : 0,
                 sys_mode_target_.load(),
                 static_cast<unsigned long>(sys_pid_target_.load()));
        OutputDebugStringA(dbg);
      }
#endif
      IMFMediaBuffer* buf = nullptr;
      const DWORD byte_count = static_cast<DWORD>(kChunkSamples * sizeof(int16_t));
      hr = MFCreateMemoryBuffer(byte_count, &buf);
      if (FAILED(hr)) {
        record_error("MFCreateMemoryBuffer failed.");
        break;
      }
      BYTE* dst = nullptr;
      buf->Lock(&dst, nullptr, nullptr);
      memcpy(dst, out_pcm.data(), byte_count);
      buf->Unlock();
      buf->SetCurrentLength(byte_count);
      IMFSample* sample = nullptr;
      hr = MFCreateSample(&sample);
      if (FAILED(hr)) {
        SafeRelease(&buf);
        record_error("MFCreateSample failed.");
        break;
      }
      sample->AddBuffer(buf);
      sample->SetSampleTime(pts_hns);
      const LONGLONG duration_hns =
          static_cast<LONGLONG>(kChunkFrames) * kHnsPerSecond /
          kTargetSampleRate;
      sample->SetSampleDuration(duration_hns);
      hr = writer->WriteSample(stream_index, sample);
      SafeRelease(&sample);
      SafeRelease(&buf);
      if (FAILED(hr)) {
        record_error("WriteSample failed.");
        break;
      }
      pts_hns += duration_hns;
      ++chunks_written;
    }
    {
      std::lock_guard<std::mutex> lock(error_mu_);
      if (!last_error_.empty()) break;
    }
  }

  // Finalise sink writer and clean up.
  HRESULT fin = writer->Finalize();
  SafeRelease(&writer);
  if (FAILED(fin)) {
    char hex[16];
    snprintf(hex, sizeof(hex), "0x%08X", static_cast<unsigned>(fin));
    record_error(std::string("Sink writer finalize failed (HRESULT ") +
                 hex + ", " + std::to_string(chunks_written) +
                 " chunks written).");
  }

  bool had_error;
  {
    std::lock_guard<std::mutex> lock(error_mu_);
    had_error = !last_error_.empty();
  }
  if (had_error) {
    // Best-effort cleanup of the partial m4a so we don't upload it.
    DeleteFileW(wpath.c_str());
  }

  // Worker exiting → meter should read silent on the next poll.
  last_level_bits_.store(DoubleToBits(0.0));

  sys_src.reset();
  SafeRelease(&enumer);

  MFShutdown();
  if (task) AvRevertMmThreadCharacteristics(task);
  if (co_init) CoUninitialize();
}
