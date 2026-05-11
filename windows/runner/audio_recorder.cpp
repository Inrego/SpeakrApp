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

#include <algorithm>
#include <cstring>
#include <vector>

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

  ~CaptureSource() {
    if (audio_client && started) audio_client->Stop();
    SafeRelease(&capture_client);
    SafeRelease(&audio_client);
    SafeRelease(&device);
    if (event) CloseHandle(event);
    if (fmt) CoTaskMemFree(fmt);
  }

  HRESULT Open(IMMDeviceEnumerator* enumer, EDataFlow flow, bool is_loopback) {
    loopback = is_loopback;
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
  if (name == "requestSystemPermission") {
    // Windows doesn't need a per-session consent for WASAPI loopback.
    result->Success(EncodableValue(true));
    return;
  }
  if (name == "isRecording") {
    result->Success(EncodableValue(running_.load() && !stop_requested_.load()));
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
    bool sys = false;
    for (const auto& kv : *args) {
      const auto* key = std::get_if<std::string>(&kv.first);
      if (!key) continue;
      if (*key == "path") {
        if (const auto* v = std::get_if<std::string>(&kv.second)) path = *v;
      } else if (*key == "micEnabled") {
        if (const auto* v = std::get_if<bool>(&kv.second)) mic = *v;
      } else if (*key == "systemEnabled") {
        if (const auto* v = std::get_if<bool>(&kv.second)) sys = *v;
      }
    }
    std::string err;
    if (!Start(path, mic, sys, &err)) {
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
  if (name == "setSystemEnabled") {
    const auto* args = std::get_if<EncodableMap>(call.arguments());
    bool v = false;
    if (args) {
      for (const auto& kv : *args) {
        if (const auto* key = std::get_if<std::string>(&kv.first)) {
          if (*key == "enabled") {
            if (const auto* b = std::get_if<bool>(&kv.second)) v = *b;
          }
        }
      }
    }
    system_enabled_.store(v);
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
    std::string path = Stop();
    if (path.empty()) {
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
                                bool system_enabled, std::string* out_error) {
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
  system_enabled_.store(system_enabled);
  paused_.store(false);
  stop_requested_.store(false);
  setup_ok_.store(false);
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

std::string SpeakrAudioRecorder::Stop() {
  if (!running_.load()) return {};
  stop_requested_.store(true);
  if (worker_.joinable()) worker_.join();
  running_.store(false);
  std::lock_guard<std::mutex> lock(error_mu_);
  if (!last_error_.empty()) {
    // Worker bailed mid-recording; the partial m4a is already deleted.
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

  CaptureSource mic_src, sys_src;
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
  hr = sys_src.Open(enumer, eRender, /*is_loopback=*/true);
  bool have_system = SUCCEEDED(hr);
  SafeRelease(&enumer);

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
    SetEvent(setup_done_event_);
    MFShutdown();
    if (task) AvRevertMmThreadCharacteristics(task);
    if (co_init) CoUninitialize();
    return;
  }
  if (have_system) {
    hr = sys_src.Start();
    if (FAILED(hr)) {
      have_system = false;  // Continue mic-only.
    }
  }

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

  // Loop until stop_requested.
  while (!stop_requested_.load()) {
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
    if (have_system) {
      dh = sys_src.Drain(/*gate_to_silence=*/!system_enabled_.load());
      if (FAILED(dh)) {
        // Loopback can transiently fail; treat as silence and keep going.
        sys_src.AppendSilence(kChunkFrames);
      }
    } else {
      sys_src.AppendSilence(kChunkFrames);
    }

    // Mix as many full chunks as both queues have ready.
    while (mic_src.pcm.size() >= kChunkSamples &&
           sys_src.pcm.size() >= kChunkSamples) {
      for (size_t i = 0; i < kChunkSamples; ++i) {
        float m = mic_src.pcm[i];
        float s = sys_src.pcm[i];
        float sum = m + s;
        if (sum > 1.0f) sum = 1.0f;
        if (sum < -1.0f) sum = -1.0f;
        out_pcm[i] = static_cast<int16_t>(sum * 32767.0f);
      }
      mic_src.pcm.erase(mic_src.pcm.begin(),
                        mic_src.pcm.begin() + kChunkSamples);
      sys_src.pcm.erase(sys_src.pcm.begin(),
                        sys_src.pcm.begin() + kChunkSamples);
      if (paused_.load()) {
        // Drop the chunk — don't advance pts. Effectively pauses the
        // timeline. (The Dart-side timer also pauses in this state.)
        continue;
      }
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
    record_error("Sink writer finalize failed.");
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

  MFShutdown();
  if (task) AvRevertMmThreadCharacteristics(task);
  if (co_init) CoUninitialize();
}
