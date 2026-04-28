import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../api/providers.dart';
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
  }

  final Ref _ref;
  final AudioRecorder _recorder = AudioRecorder();
  Timer? _ticker;
  WindowController? _miniController;
  bool _ipcRegistered = false;

  final _navController = StreamController<RecordingNav>.broadcast();
  Stream<RecordingNav> get navStream => _navController.stream;

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
      case MiniIpc.cmdAddCustomTag:
        final name = (call.arguments as Map?)?['name'];
        if (name is String) addCustomTag(name);
        return null;
      case MiniIpc.cmdBeginDrag:
        await MiniWindowNative.beginMiniDrag();
        return null;
    }
    return null;
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

  // ---------------- Public actions ----------------

  Future<void> start() async {
    if (state.started) return;
    state = state.copyWith(error: null);
    final granted = await Permission.microphone.request();
    if (!granted.isGranted) {
      state = state.copyWith(error: 'Microphone permission is required to record.');
      return;
    }
    if (!await _recorder.hasPermission()) {
      state = state.copyWith(error: 'Recorder reports no permission.');
      return;
    }
    final dir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final path = '${dir.path}${Platform.pathSeparator}speakr_$ts.m4a';
    try {
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );
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
    }
  }

  Future<void> togglePause() async {
    if (!state.started) return;
    if (state.paused) {
      await _recorder.resume();
    } else {
      await _recorder.pause();
    }
    state = state.copyWith(paused: !state.paused);
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
      await api.uploadRecording(
        file: file,
        minSpeakers: state.speakers,
        maxSpeakers: state.speakers,
        tagIds: tagIds,
        fileLastModified: stat.modified,
      );
      _ref.invalidate(libraryRecordingsProvider);
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

  void toggleTag(String name) {
    final tags = [...state.activeTags];
    if (tags.contains(name)) {
      tags.remove(name);
    } else {
      tags.add(name);
    }
    state = state.copyWith(activeTags: tags);
  }

  void addCustomTag(String name) {
    final v = name.trim();
    if (v.isEmpty) return;
    if (state.activeTags.contains(v)) return;
    state = state.copyWith(activeTags: [...state.activeTags, v]);
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
    state = const RecordingState();
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
