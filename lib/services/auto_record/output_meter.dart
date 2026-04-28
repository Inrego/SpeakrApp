import 'dart:async';
import 'dart:ffi';
import 'dart:io' show Platform;

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:win32/win32.dart';

/// Reports the peak output level (0.0–1.0) of the default render
/// endpoint. We use this on Windows to detect when speaker output is
/// silent — combined with mic-released, that's the signal to ask the
/// user whether to stop the auto-recording.
///
/// `package:win32` 5.15 doesn't ship a generated `IAudioMeterInformation`
/// binding, so the interface vtable is called directly here. The IID is
/// stable since Vista. Only `GetPeakValue` (vtable index 3) is used.
abstract class OutputMeter {
  /// Stream of peak values (0.0 – 1.0). Emits at the configured
  /// interval; on errors emits 0.0 and keeps trying.
  Stream<double> get peaks;
  Future<void> dispose();
}

OutputMeter createOutputMeter({
  Duration sampleInterval = const Duration(milliseconds: 500),
}) {
  if (Platform.isWindows) return _WindowsOutputMeter(sampleInterval);
  return _NoopOutputMeter();
}

class _NoopOutputMeter implements OutputMeter {
  @override
  Stream<double> get peaks => const Stream<double>.empty();

  @override
  Future<void> dispose() async {}
}

const String _iidIAudioMeterInformation =
    '{C02216F6-8C67-4B5B-9D00-D008E73E0064}';

class _WindowsOutputMeter implements OutputMeter {
  _WindowsOutputMeter(this.interval) {
    _ctrl = StreamController<double>.broadcast(
      onListen: _start,
      onCancel: _stop,
    );
  }

  final Duration interval;
  late final StreamController<double> _ctrl;
  Timer? _timer;
  Pointer<COMObject>? _meter;
  bool _comInitialized = false;

  @override
  Stream<double> get peaks => _ctrl.stream;

  void _start() {
    _ensureMeter();
    _timer ??= Timer.periodic(interval, (_) => _tick());
    // Fire one immediately so callers don't wait an interval for the
    // first sample.
    Future<void>.microtask(_tick);
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    _release();
  }

  void _tick() {
    final peak = _readPeak();
    if (!_ctrl.isClosed) _ctrl.add(peak);
  }

  /// Lazily acquire the device + meter. Recreated transparently after
  /// device-change errors (e.g. user unplugging a USB headset).
  void _ensureMeter() {
    if (_meter != null) return;
    try {
      if (!_comInitialized) {
        // Each thread that calls a COM API must have a COM apartment.
        // Flutter's main isolate doesn't initialize COM by default
        // (it's done in the platform thread, not the Dart isolate).
        final hr =
            CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
        // RPC_E_CHANGED_MODE = 0x80010106 — already initialized with a
        // different mode, harmless.
        if (hr == S_OK || hr == S_FALSE || hr == 0x80010106.toSigned(32)) {
          _comInitialized = true;
        }
      }

      final enumerator = MMDeviceEnumerator.createInstance();
      try {
        final ppDevice = calloc<Pointer<COMObject>>();
        try {
          final hr =
              enumerator.getDefaultAudioEndpoint(0 /* eRender */, 1 /* eMultimedia */, ppDevice);
          if (FAILED(hr) || ppDevice.value == nullptr) return;
          final device = IMMDevice(ppDevice.value);
          try {
            final iid = convertToIID(_iidIAudioMeterInformation);
            final ppMeter = calloc<Pointer<COMObject>>();
            try {
              final ar = device.activate(iid, CLSCTX_ALL, nullptr, ppMeter.cast());
              if (FAILED(ar) || ppMeter.value == nullptr) return;
              _meter = ppMeter.value;
            } finally {
              free(iid);
              // ppMeter itself is freed; the COM object survives via _meter.
              free(ppMeter);
            }
          } finally {
            device.release();
          }
        } finally {
          free(ppDevice);
        }
      } finally {
        enumerator.release();
      }
    } catch (e, st) {
      debugPrint('[output-meter] could not acquire meter: $e\n$st');
    }
  }

  double _readPeak() {
    final m = _meter;
    if (m == null) {
      // Try to recover after a transient device change.
      _ensureMeter();
      return 0.0;
    }
    final peakOut = calloc<Float>();
    try {
      // IAudioMeterInformation::GetPeakValue is at vtable index 3
      // (after IUnknown's 3 entries).
      final fn = (m.ref.vtable + 3)
          .cast<
              Pointer<
                  NativeFunction<
                      Int32 Function(Pointer, Pointer<Float> pfPeak)>>>()
          .value
          .asFunction<int Function(Pointer, Pointer<Float> pfPeak)>();
      final hr = fn(m.ref.lpVtbl, peakOut);
      if (FAILED(hr)) {
        // 0x88890004 = AUDCLNT_E_DEVICE_INVALIDATED. Drop the cached
        // meter so the next tick re-acquires the new default endpoint.
        _release();
        return 0.0;
      }
      return peakOut.value;
    } catch (_) {
      _release();
      return 0.0;
    } finally {
      free(peakOut);
    }
  }

  void _release() {
    final m = _meter;
    if (m != null) {
      try {
        // IUnknown::Release at vtable index 2.
        final fn = (m.ref.vtable + 2)
            .cast<Pointer<NativeFunction<Uint32 Function(Pointer)>>>()
            .value
            .asFunction<int Function(Pointer)>();
        fn(m.ref.lpVtbl);
      } catch (_) {}
      free(m);
      _meter = null;
    }
  }

  @override
  Future<void> dispose() async {
    _stop();
    if (_comInitialized) {
      try {
        CoUninitialize();
      } catch (_) {}
      _comInitialized = false;
    }
    if (!_ctrl.isClosed) await _ctrl.close();
  }
}
