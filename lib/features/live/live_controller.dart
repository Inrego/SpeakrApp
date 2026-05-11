import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:path_provider/path_provider.dart';

import '../../api/models.dart';
import '../../api/providers.dart';
import '../../services/audio/live_audio_recorder.dart';
import '../../services/audio/live_audio_recorder_factory.dart';
import '../../services/auto_record/auto_record_providers.dart';
import '../../services/auto_record/auto_record_settings.dart';
import '../../routing/router.dart';
import '../library/library_controller.dart';
import 'mini/mini_ipc.dart';
import 'mini/mini_window_native.dart';
import 'recording_state.dart';

/// Events the controller asks the live UI to act on (since notifiers can't
/// hold a [BuildContext]).
enum RecordingNav { toLibrary, pop }

class RecordingController extends StateNotifier<RecordingState> {
  RecordingController(this._ref) : super(const RecordingState()) {
    _registerMainIpcHandler();
    addListener(_pushStateToMini, fireImmediately: false);
    _ref.listen<AsyncValue<List<Tag>>>(tagsProvider, (_, next) {
      final tags = next.value;
      if (tags == null) return;
      if (state.miniOpen) _pushTagsToMini(tags);
    });
    // Re-push folder list to the mini whenever the main app's folders
    // provider updates (e.g. after a refresh) and a mini window is open.
    _ref.listen<AsyncValue<List<Folder>>>(foldersProvider, (_, next) {
      final list = next.value;
      if (list != null) _pushFoldersToMini(list);
    });
    // Start with a fallback recorder so the controller is usable
    // synchronously; probe for the native pipeline in the background and
    // swap once available. Sets `state.systemAudioSupported` so the UI
    // can enable the System Audio toggle when capable.
    _initRecorder();
  }

  final Ref _ref;
  LiveAudioRecorder _recorder = LiveAudioRecorderFactory.createSync();
  bool _recorderProbed = false;
  Timer? _ticker;
  WindowController? _miniController;
  bool _ipcRegistered = false;
  DateTime? _recordingStartedAt;

  final _navController = StreamController<RecordingNav>.broadcast();
  Stream<RecordingNav> get navStream => _navController.stream;

  Future<void> _initRecorder() async {
    try {
      final r = await LiveAudioRecorderFactory.createAsync();
      if (_recorderProbed) {
        // Race: controller disposed during probe.
        await r.dispose();
        return;
      }
      final old = _recorder;
      _recorder = r;
      _recorderProbed = true;
      if (state.systemAudioSupported != r.supportsSystemAudio) {
        state = state.copyWith(systemAudioSupported: r.supportsSystemAudio);
      }
      // The fallback recorder we constructed synchronously is no longer
      // needed once the native one is wired up.
      if (!identical(old, r)) {
        await old.dispose();
      }
    } catch (e) {
      debugPrint('Recorder probe failed: $e');
    }
  }

  void _registerMainIpcHandler() {
    if (kIsWeb || !Platform.isWindows) return;
    if (_ipcRegistered) return;
    try {
      DesktopMultiWindow.setMethodHandler(_handleMiniCommand);
      _ipcRegistered = true;
    } catch (_) {
      // Embedder not available (tests); silent.
    }
  }

  Future<dynamic> _handleMiniCommand(MethodCall call, int fromWindowId) async {
    switch (call.method) {
      case MiniIpc.cmdTogglePause:
        await togglePause();
        return null;
      case MiniIpc.cmdStop:
        await stopAndUpload();
        return null;
      case MiniIpc.cmdCancel:
        await cancel();
        return null;
      case MiniIpc.cmdHideMini:
        await hideMini();
        return null;
      case MiniIpc.cmdSetSpeakers:
        final v = (call.arguments as Map?)?['value'];
        if (v is int) setSpeakers(v);
        return null;
      case MiniIpc.cmdToggleTag:
        final name = (call.arguments as Map?)?['name'];
        if (name is String) toggleTag(name);
        return null;
      case MiniIpc.cmdSetFolder:
        final id = (call.arguments as Map?)?['id'];
        if (id == null) {
          setFolder(null);
        } else if (id is int) {
          setFolder(id);
        }
        return null;
      case MiniIpc.cmdSetMicEnabled:
        final v = (call.arguments as Map?)?['enabled'];
        if (v is bool) await setMicEnabled(v);
        return null;
      case MiniIpc.cmdSetSystemEnabled:
        final v = (call.arguments as Map?)?['enabled'];
        if (v is bool) await setSystemEnabled(v);
        return null;
      case MiniIpc.cmdBeginDrag:
        await MiniWindowNative.beginMiniDrag();
        return null;
      case MiniIpc.cmdShowMain:
        await MiniWindowNative.focusMain();
        // Route the main app to /live so the user lands on the recording
        // page, not whatever screen they were on before opening the pill.
        try {
          _ref.read(routerProvider).go('/live');
        } catch (_) {}
        return null;
    }
    return null;
  }

  void _pushFoldersToMini(List<Folder> folders) {
    final mini = _miniController;
    if (mini == null || !state.miniOpen) return;
    DesktopMultiWindow.invokeMethod(
      mini.windowId,
      MiniIpc.foldersUpdate,
      jsonEncode([for (final f in folders) f.toJson()]),
    ).catchError((_) => null);
  }

  void _pushStateToMini(RecordingState s) {
    final mini = _miniController;
    if (mini == null || !s.miniOpen) return;
    DesktopMultiWindow.invokeMethod(
      mini.windowId,
      MiniIpc.stateUpdate,
      jsonEncode(s.toJson()),
    ).catchError((_) => null);
  }

  void _pushTagsToMini(List<Tag> tags) {
    final mini = _miniController;
    if (mini == null) return;
    DesktopMultiWindow.invokeMethod(
      mini.windowId,
      MiniIpc.tagsUpdate,
      jsonEncode([for (final t in tags) t.toJson()]),
    ).catchError((_) => null);
  }

  // ---------------- Public actions ----------------

  /// Start a new recording. When [micEnabled] / [systemEnabled] are
  /// passed (auto-record coordinator path), those values win; otherwise
  /// the controller falls back to [AutoRecordSettings.defaultMicEnabled]
  /// / [AutoRecordSettings.defaultSystemEnabled]. The system flag is
  /// silently downgraded to false on platforms where the recorder can't
  /// capture system audio.
  Future<void> start({bool? micEnabled, bool? systemEnabled}) async {
    if (state.started) return;
    state = state.copyWith(error: null);

    bool mic;
    bool sys;
    if (micEnabled != null && systemEnabled != null) {
      mic = micEnabled;
      sys = systemEnabled;
    } else {
      AutoRecordSettings settings;
      try {
        settings = await _ref.read(autoRecordSettingsProvider.future);
      } catch (_) {
        settings = const AutoRecordSettings();
      }
      mic = micEnabled ?? settings.defaultMicEnabled;
      sys = systemEnabled ?? settings.defaultSystemEnabled;
    }
    if (sys && !_recorder.supportsSystemAudio) sys = false;
    // At least one source must be on at session start, so the user
    // gets a meaningful recording. If both got resolved to off, fall
    // back to mic on — that matches the prior plugin behavior.
    if (!mic && !sys) mic = true;

    state = state.copyWith(
      micEnabled: mic,
      systemEnabled: sys,
      systemAudioSupported: _recorder.supportsSystemAudio,
    );

    if (mic) {
      final granted = await _recorder.requestMicPermission();
      if (!granted) {
        state =
            state.copyWith(error: 'Microphone permission is required to record.');
        return;
      }
    }
    if (sys) {
      final ok = await _recorder.requestSystemPermission();
      if (!ok) {
        if (!mic) {
          state = state.copyWith(error: 'System-audio permission was denied.');
          return;
        }
        // Continue mic-only.
        sys = false;
        state = state.copyWith(
          systemEnabled: false,
          error: 'System-audio permission was denied — continuing with mic only.',
        );
      }
    }

    final dir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final path = '${dir.path}${Platform.pathSeparator}speakr_$ts.m4a';
    try {
      await _recorder.start(
        path: path,
        micEnabled: mic,
        systemEnabled: sys,
      );
      _recordingStartedAt = DateTime.now();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!state.paused) {
          state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
        }
      });
      state = state.copyWith(started: true);
      if (!kIsWeb && Platform.isWindows) {
        await _openMiniWindow();
      }
    } catch (e) {
      state = state.copyWith(error: 'Could not start recording: $e');
      await _cleanupAfterFailure();
    }
  }

  Future<void> togglePause() async {
    if (!state.started) return;
    try {
      if (state.paused) {
        await _recorder.resume();
      } else {
        await _recorder.pause();
      }
      state = state.copyWith(paused: !state.paused);
    } catch (e) {
      state = state.copyWith(error: 'Failed to toggle pause: $e');
    }
  }

  /// Toggle the mic source. Effective immediately on platforms with
  /// live mic-mute support (Windows, Android); on the fallback path
  /// (iOS / web) this is mapped to pause/resume and the [state.paused]
  /// flag tracks the effect.
  Future<void> setMicEnabled(bool v) async {
    if (state.micPending) return;
    if (state.micEnabled == v && state.started) return;
    if (!state.started) {
      // Pre-start: just stash the choice for the next [start] call.
      state = state.copyWith(micEnabled: v);
      return;
    }
    state = state.copyWith(micPending: true);
    try {
      await _recorder.setMicEnabled(v);
      if (_recorder.supportsLiveMicToggle) {
        state = state.copyWith(micEnabled: v, micPending: false);
      } else {
        // Fallback: mic-off implies paused.
        state = state.copyWith(
          micEnabled: v,
          micPending: false,
          paused: !v,
        );
      }
    } catch (e) {
      state = state.copyWith(
        micPending: false,
        error: 'Failed to toggle mic: $e',
      );
    }
  }

  /// Toggle the system-audio source. Effective immediately on platforms
  /// with live source-mute support (Windows, Android); throws (via
  /// surfaced error state) on platforms where it isn't supported.
  Future<void> setSystemEnabled(bool v) async {
    if (state.systemPending) return;
    if (v && !_recorder.supportsSystemAudio) {
      state = state.copyWith(
          error: 'System audio capture isn\'t supported on this device.');
      return;
    }
    if (state.systemEnabled == v && state.started) return;
    if (!state.started) {
      state = state.copyWith(systemEnabled: v);
      return;
    }
    state = state.copyWith(systemPending: true);
    try {
      if (v) {
        final ok = await _recorder.requestSystemPermission();
        if (!ok) {
          state = state.copyWith(
            systemPending: false,
            error: 'System-audio permission was denied.',
          );
          return;
        }
      }
      await _recorder.setSystemEnabled(v);
      state = state.copyWith(systemEnabled: v, systemPending: false);
    } catch (e) {
      state = state.copyWith(
        systemPending: false,
        error: 'Failed to toggle system audio: $e',
      );
    }
  }

  Future<void> stopAndUpload() async {
    if (!state.started || state.uploading) return;
    state = state.copyWith(uploading: true);
    try {
      final path = await _recorder.stop();
      _ticker?.cancel();
      _ticker = null;
      if (path == null) {
        throw Exception('Recorder returned no file path.');
      }
      final file = File(path);
      final api = _ref.read(speakrApiProvider);

      // Map active tag names → ids when known; otherwise upload still
      // succeeds and the user can attach tags from Detail.
      final tagsAsync = _ref.read(tagsProvider);
      final knownTags = tagsAsync.value ?? const [];
      final tagIds = <int>[
        for (final name in state.activeTags)
          for (final t in knownTags)
            if (t.name.toLowerCase() == name.toLowerCase()) t.id,
      ];

      final stat = await file.stat();
      final recording = await api.uploadRecording(
        file: file,
        minSpeakers: state.speakers,
        maxSpeakers: state.speakers,
        tagIds: tagIds,
        folderId: state.folderId,
        fileLastModified: stat.modified,
      );
      final startedAt = _recordingStartedAt;
      if (startedAt != null) {
        try {
          await api.updateRecording(recording.id, {
            'meeting_date': startedAt.toUtc().toIso8601String(),
          });
        } catch (e) {
          debugPrint('meeting_date PATCH failed for ${recording.id}: $e');
        }
      }
      _ref.read(uploadKickProvider.notifier).state++;
      try {
        await file.delete();
      } catch (_) {}

      await _closeMiniWindow();
      _resetSession();
      _navController.add(RecordingNav.toLibrary);
    } catch (e) {
      state = state.copyWith(
        uploading: false,
        error: 'Upload failed: $e',
      );
    }
  }

  Future<void> cancel() async {
    _ticker?.cancel();
    _ticker = null;
    try {
      if (await _recorder.isRecording()) {
        final path = await _recorder.stop();
        if (path != null) {
          try {
            await File(path).delete();
          } catch (_) {}
        }
      }
    } catch (_) {}

    await _closeMiniWindow();
    _resetSession();
    _navController.add(RecordingNav.pop);
  }

  void setSpeakers(int v) {
    state = state.copyWith(speakers: v.clamp(1, 12));
  }

  void setFolder(int? id) {
    state = state.copyWith(folderId: id);
  }

  void toggleTag(String name) {
    final tags = [...state.activeTags];
    if (tags.contains(name)) {
      tags.remove(name);
    } else {
      tags.add(name);
    }
    state = state.copyWith(activeTags: tags);
  }

  void setActiveTags(List<String> names) {
    state = state.copyWith(activeTags: List.unmodifiable(names));
  }

  Future<void> _cleanupAfterFailure() async {
    _ticker?.cancel();
    _ticker = null;
    try {
      if (await _recorder.isRecording()) {
        final path = await _recorder.stop();
        if (path != null) {
          try {
            await File(path).delete();
          } catch (_) {}
        }
      }
    } catch (_) {}
    await _closeMiniWindow();
  }

  // ---------------- Mini window lifecycle ----------------

  /// Hide the mini-window without touching the recorder. Recording, ticker
  /// and `/live` route stay live; the user can bring the mini back via
  /// [openMini].
  Future<void> hideMini() async {
    await _closeMiniWindow();
    state = state.copyWith(miniOpen: false, miniWindowId: null);
  }

  /// (Re)open the mini-window while a recording is active. Windows-only.
  Future<void> openMini() async {
    if (kIsWeb || !Platform.isWindows) return;
    if (!state.started) return;
    if (state.miniOpen) return;
    await _openMiniWindow();
  }

  Future<void> _openMiniWindow() async {
    if (_miniController != null) return;
    try {
      final c = await DesktopMultiWindow.createWindow(
        jsonEncode({'role': MiniIpc.argRoleMini}),
      );
      _miniController = c;
      await c.setTitle('Speakr Recording');
      await c.show();
      // Update state — listener will push the current snapshot to the mini.
      state = state.copyWith(miniOpen: true, miniWindowId: c.windowId);
      // Push initial server tags so the mini's suggestion list matches main.
      final initialTags = _ref.read(tagsProvider).value;
      if (initialTags != null) _pushTagsToMini(initialTags);
      // Push the folder list so the mini can render its picker. Reference
      // data isn't part of RecordingState, so it goes via its own IPC call.
      final folders = _ref.read(foldersProvider).value ?? const <Folder>[];
      _pushFoldersToMini(folders);
      // Apply always-on-top + tool-window styles + initial frame via the
      // native helper (the package doesn't expose these on Windows).
      await MiniWindowNative.applyMiniChrome();
    } catch (_) {
      // If we can't open, recording still proceeds in the main window.
      _miniController = null;
      state = state.copyWith(miniOpen: false, miniWindowId: null);
    }
  }

  Future<void> _closeMiniWindow() async {
    final mini = _miniController;
    if (mini == null) return;
    try {
      // Tell the mini to tear down its UI before we close the host window.
      await DesktopMultiWindow.invokeMethod(
        mini.windowId,
        MiniIpc.lifecycleClose,
        null,
      );
    } catch (_) {}
    try {
      await mini.close();
    } catch (_) {}
    // Belt-and-braces: kill via native too.
    await MiniWindowNative.closeMini();
    _miniController = null;
  }

  void _resetSession() {
    _recordingStartedAt = null;
    state = RecordingState(
      // Preserve capability flag across sessions — it doesn't change at
      // runtime and re-probing would waste a round trip.
      systemAudioSupported: state.systemAudioSupported,
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _recorder.dispose();
    _navController.close();
    super.dispose();
  }
}

final recordingControllerProvider =
    StateNotifierProvider<RecordingController, RecordingState>(
  (ref) => RecordingController(ref),
);
