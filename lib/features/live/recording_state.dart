import 'package:freezed_annotation/freezed_annotation.dart';

part 'recording_state.freezed.dart';
part 'recording_state.g.dart';

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
    @Default(false) bool systemEnabled,
    @Default(false) bool systemAudioSupported,
    @Default(false) bool micPending,
    @Default(false) bool systemPending,
    @Default(0.0) double audioLevel,
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
}
