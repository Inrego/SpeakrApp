import 'package:freezed_annotation/freezed_annotation.dart';

part 'recording_state.freezed.dart';
part 'recording_state.g.dart';

/// Mode of the system-audio capture source.
///
/// * [off] — no system audio is recorded.
/// * [allSystem] — Windows WASAPI loopback against the default render
///   endpoint (every app's audio mixes in).
/// * [processOnly] — Windows process loopback via `ActivateAudioInterfaceAsync`
///   with `AUDIOCLIENT_ACTIVATION_TYPE_PROCESS_LOOPBACK`. Only audio
///   from the trigger process tree is captured. Requires Windows build
///   ≥ 20348 (Server 2022 / Windows 11).
enum SystemAudioMode { off, allSystem, processOnly }

/// State shared between the main recording UI and the Windows-only
/// always-on-top mini window. Serializable for IPC.
@freezed
sealed class RecordingState with _$RecordingState {
  const RecordingState._();

  const factory RecordingState({
    @Default(0) int elapsedSeconds,
    @Default(false) bool paused,
    @Default(false) bool started,
    @Default(false) bool uploading,
    String? error,
    @Default(2) int speakers,
    @Default(<String>[]) List<String> activeTags,
    int? folderId,
    @Default(false) bool miniOpen,
    int? miniWindowId,
    @Default(true) bool micEnabled,
    @Default(SystemAudioMode.off) SystemAudioMode systemMode,
    @Default(false) bool systemAudioSupported,
    @Default(false) bool processLoopbackSupported,
    @Default(false) bool micPending,
    @Default(false) bool systemPending,
    @Default(0.0) double audioLevel,
    String? processSourceName,
    int? processSourcePid,
  }) = _RecordingState;

  factory RecordingState.fromJson(Map<String, dynamic> json) =>
      _$RecordingStateFromJson(json);

  Duration get elapsed => Duration(seconds: elapsedSeconds);

  String get formattedElapsed {
    final h = elapsed.inHours;
    final m = elapsed.inMinutes % 60;
    final s = elapsed.inSeconds % 60;
    final ss = s.toString().padLeft(2, '0');
    if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:$ss';
    return '$m:$ss';
  }

  /// Convenience — true unless the system source is `off`.
  bool get systemEnabled => systemMode != SystemAudioMode.off;
}
