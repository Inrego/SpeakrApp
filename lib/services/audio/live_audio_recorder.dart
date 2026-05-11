/// Abstraction over the per-platform recording pipeline used by the
/// live-recording session.
///
/// The Flutter `record` plugin only supports mic and can't change source
/// mid-stream, which doesn't match Speakr's "mic / system / both, switchable
/// during recording" UX. On Windows and Android we ship native pipelines
/// (WASAPI loopback / MediaProjection AudioPlaybackCapture) behind this
/// interface; iOS and web fall back to a mic-only wrapper over `record`.
abstract class LiveAudioRecorder {
  /// Whether the host platform can capture system (loopback) audio in
  /// addition to mic. UI must hide / disable the system toggle when false.
  bool get supportsSystemAudio;

  /// Whether the mic source can be muted live (zero-filled into the
  /// output file) without pausing the encoder. When false, the live
  /// screen should treat mic-off as a pause/resume rather than a per-source
  /// gate.
  bool get supportsLiveMicToggle;

  /// True if the recorder is currently writing to a file.
  Future<bool> isRecording();

  /// Check (without prompting) whether mic permission is granted.
  Future<bool> hasMicPermission();

  /// Request mic permission (no-op on platforms where capture
  /// implementations request it directly).
  Future<bool> requestMicPermission();

  /// Ask the OS for permission to capture system audio. On Android this
  /// shows the per-session `MediaProjection` consent dialog. On Windows
  /// it's a no-op (returns true). On unsupported platforms returns false.
  Future<bool> requestSystemPermission();

  /// Begin a new recording. Both source flags determine whether the
  /// corresponding stream is initially mixed in; sources can later be
  /// flipped via `setMicEnabled` / `setSystemEnabled` without stopping.
  Future<void> start({
    required String path,
    required bool micEnabled,
    required bool systemEnabled,
  });

  /// Pause/resume the encoder. While paused, no frames (silence or audio)
  /// are appended to the file; on resume the timeline continues from
  /// where it left off, with PTS rewritten so there's no synthetic gap.
  Future<void> pause();
  Future<void> resume();

  /// Toggle the microphone source. Effective immediately; while disabled,
  /// the mixer substitutes zero-filled PCM blocks for the mic stream so
  /// the encoded file stays continuous.
  Future<void> setMicEnabled(bool enabled);

  /// Toggle the system-audio source. Effective immediately; while
  /// disabled, the mixer substitutes zero-filled PCM blocks for the
  /// system stream. Throws `UnsupportedError` on platforms where
  /// [supportsSystemAudio] is false.
  Future<void> setSystemEnabled(bool enabled);

  /// Finalise the recording and return the file path, or `null` if the
  /// recording could not be saved (in which case any partial file has
  /// already been deleted by the implementation).
  Future<String?> stop();

  /// Release any held resources. Idempotent.
  Future<void> dispose();
}
