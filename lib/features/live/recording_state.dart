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
  }) = _RecordingState;

  factory RecordingState.fromJson(Map<String, dynamic> json) =>
      _$RecordingStateFromJson(json);

  Duration get elapsed => Duration(seconds: elapsedSeconds);

  String get formattedElapsed {
    final m = elapsed.inMinutes;
    final s = elapsed.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
