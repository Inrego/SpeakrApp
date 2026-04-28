import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../api/providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/mono_eyebrow.dart';
import '../../widgets/speakr_icons.dart';
import '../../widgets/tag_chip.dart';
import '../library/library_controller.dart';

class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({super.key});

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen> {
  final _recorder = AudioRecorder();
  Timer? _ticker;
  Duration _elapsed = Duration.zero;
  bool _paused = false;
  bool _started = false;
  String? _error;
  bool _uploading = false;

  int _speakers = 2;
  final Set<String> _activeTags = {'Internal'};
  bool _tagPickerOpen = false;
  final _newTagCtrl = TextEditingController();
  bool _customTagsAdded = false;

  static const _allTags = <(String, Color)>[
    ('Internal', SpeakrColors.tagInternal),
    ('1:1', SpeakrColors.tag1on1),
    ('Customer', SpeakrColors.tagCustomer),
    ('Roadmap', SpeakrColors.tagRoadmap),
    ('Design', SpeakrColors.tagDesign),
    ('Personal', SpeakrColors.tagPersonal),
    ('Engineering', SpeakrColors.tagEngineering),
  ];

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _recorder.dispose();
    _newTagCtrl.dispose();
    super.dispose();
  }

  Color _colorFor(String name) {
    final preset = _allTags.firstWhere(
      (t) => t.$1 == name,
      orElse: () => ('', SpeakrColors.ink),
    );
    return preset.$1.isEmpty ? SpeakrColors.ink : preset.$2;
  }

  Future<void> _start() async {
    final granted = await Permission.microphone.request();
    if (!granted.isGranted) {
      if (!mounted) return;
      setState(() {
        _error = 'Microphone permission is required to record.';
      });
      return;
    }
    if (!await _recorder.hasPermission()) {
      if (!mounted) return;
      setState(() => _error = 'Recorder reports no permission.');
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
        if (!_paused && mounted) {
          setState(() => _elapsed += const Duration(seconds: 1));
        }
      });
      if (mounted) setState(() => _started = true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Could not start recording: $e');
    }
  }

  Future<void> _togglePause() async {
    if (_paused) {
      await _recorder.resume();
    } else {
      await _recorder.pause();
    }
    if (mounted) setState(() => _paused = !_paused);
  }

  Future<void> _stopAndUpload() async {
    if (!_started || _uploading) return;
    setState(() => _uploading = true);
    try {
      final path = await _recorder.stop();
      _ticker?.cancel();
      if (path == null) {
        throw Exception('Recorder returned no file path.');
      }
      final file = File(path);
      final api = ref.read(speakrApiProvider);

      // Map active tag names to ids when we know them; otherwise the upload
      // succeeds and the user can attach tags from Detail.
      final tagsAsync = ref.read(tagsProvider);
      final knownTags = tagsAsync.value ?? const [];
      final tagIds = <int>[
        for (final name in _activeTags)
          for (final t in knownTags)
            if (t.name.toLowerCase() == name.toLowerCase()) t.id,
      ];

      final stat = await file.stat();
      await api.uploadRecording(
        file: file,
        minSpeakers: _speakers,
        maxSpeakers: _speakers,
        tagIds: tagIds,
        fileLastModified: stat.modified,
      );
      ref.invalidate(libraryRecordingsProvider);
      try {
        await file.delete();
      } catch (_) {}
      if (!mounted) return;
      context.go('/library');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _error = 'Upload failed: $e';
      });
    }
  }

  Future<void> _cancel() async {
    _ticker?.cancel();
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
    if (mounted) context.pop();
  }

  String get _formattedElapsed {
    final m = _elapsed.inMinutes;
    final s = _elapsed.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpeakrColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onCancel: _cancel),
            const SizedBox(height: 4),
            _LiveIndicator(paused: _paused),
            const SizedBox(height: 18),
            _Timer(text: _formattedElapsed),
            const Spacer(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _error!,
                  style: SpeakrText.sans(size: 13, color: SpeakrColors.danger),
                ),
              ),
            const SizedBox(height: 12),
            _MetadataCard(
              speakers: _speakers,
              onSpeakersChanged: (v) => setState(() => _speakers = v),
              activeTags: _activeTags,
              tagPickerOpen: _tagPickerOpen,
              onToggleTag: (name) {
                setState(() {
                  if (_activeTags.contains(name)) {
                    _activeTags.remove(name);
                  } else {
                    _activeTags.add(name);
                  }
                });
              },
              onToggleEdit: () =>
                  setState(() => _tagPickerOpen = !_tagPickerOpen),
              colorFor: _colorFor,
              allPresetTags: _allTags,
              newTagCtrl: _newTagCtrl,
              onAddCustom: () {
                final v = _newTagCtrl.text.trim();
                if (v.isEmpty) return;
                setState(() {
                  _activeTags.add(v);
                  _newTagCtrl.clear();
                  _customTagsAdded = true;
                });
              },
              customTagsAdded: _customTagsAdded,
            ),
            _Controls(
              paused: _paused,
              busy: _uploading,
              onTogglePause: _started ? _togglePause : null,
              onStop: _started ? _stopAndUpload : null,
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onCancel});
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GhostIconButton(icon: SpeakrIcon.close, onTap: onCancel),
          const MonoEyebrow('Recording', size: 10),
          const SizedBox(width: 36),
        ],
      ),
    );
  }
}

class _LiveIndicator extends StatefulWidget {
  const _LiveIndicator({required this.paused});
  final bool paused;
  @override
  State<_LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<_LiveIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
        ..repeat(reverse: true);
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.paused
              ? const _Dot()
              : FadeTransition(
                  opacity: Tween(begin: 1.0, end: 0.3).animate(_ctrl),
                  child: const _Dot(),
                ),
          const SizedBox(width: 8),
          Text(
            widget.paused ? 'PAUSED' : 'LIVE',
            style: SpeakrText.mono(
              size: 11,
              color: SpeakrColors.recordingDot,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) => Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: SpeakrColors.recordingDot,
          shape: BoxShape.circle,
        ),
      );
}

class _Timer extends StatelessWidget {
  const _Timer({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          text,
          style: SpeakrText.serif(
            size: 56,
            weight: FontWeight.w300,
            height: 1,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 10),
        MonoEyebrow(
          'New recording · ${_today()}',
          size: 11,
        ),
      ],
    );
  }

  static String _today() {
    final d = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}';
  }
}

class _MetadataCard extends StatelessWidget {
  const _MetadataCard({
    required this.speakers,
    required this.onSpeakersChanged,
    required this.activeTags,
    required this.tagPickerOpen,
    required this.onToggleTag,
    required this.onToggleEdit,
    required this.colorFor,
    required this.allPresetTags,
    required this.newTagCtrl,
    required this.onAddCustom,
    required this.customTagsAdded,
  });
  final int speakers;
  final ValueChanged<int> onSpeakersChanged;
  final Set<String> activeTags;
  final bool tagPickerOpen;
  final ValueChanged<String> onToggleTag;
  final VoidCallback onToggleEdit;
  final Color Function(String) colorFor;
  final List<(String, Color)> allPresetTags;
  final TextEditingController newTagCtrl;
  final VoidCallback onAddCustom;
  final bool customTagsAdded;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        border: Border.all(color: SpeakrColors.line),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MonoEyebrow('Speakers', size: 9),
                      const SizedBox(height: 2),
                      Text(
                        'Helps separate voices.',
                        style: SpeakrText.sans(
                            size: 11,
                            color: SpeakrColors.muted,
                            weight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                _StepperButton(
                  child: '−',
                  onTap: () =>
                      onSpeakersChanged((speakers - 1).clamp(1, 12)),
                ),
                const SizedBox(width: 14),
                SizedBox(
                  width: 22,
                  child: Center(
                    child: Text(
                      '$speakers',
                      style: SpeakrText.serif(size: 24, height: 1),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                _StepperButton(
                  child: '+',
                  onTap: () =>
                      onSpeakersChanged((speakers + 1).clamp(1, 12)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: SpeakrColors.line)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const MonoEyebrow('Tags', size: 9),
                    InkWell(
                      onTap: onToggleEdit,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: MonoEyebrow(
                          tagPickerOpen ? 'Done' : 'Edit',
                          size: 9,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    if (activeTags.isEmpty && !tagPickerOpen)
                      Text(
                        'None yet',
                        style: SpeakrText.sans(
                            size: 12,
                            color: SpeakrColors.muted),
                      ),
                    for (final name in activeTags)
                      CustomColorTagChip(
                        label: name,
                        color: colorFor(name),
                        filled: true,
                        onTap: tagPickerOpen ? () => onToggleTag(name) : null,
                        trailing: tagPickerOpen
                            ? Text('×',
                                style: SpeakrText.serif(
                                  size: 11,
                                  color: colorFor(name)
                                      .withValues(alpha: 0.6),
                                ))
                            : null,
                      ),
                  ],
                ),
                if (tagPickerOpen) ...[
                  const SizedBox(height: 10),
                  const Divider(
                      color: SpeakrColors.line, thickness: 1, height: 1),
                  const SizedBox(height: 10),
                  const MonoEyebrow('Suggested', size: 9),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (final t in allPresetTags)
                        if (!activeTags.contains(t.$1))
                          DashedTagChip(
                            label: t.$1,
                            color: t.$2,
                            onTap: () => onToggleTag(t.$1),
                          ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: newTagCtrl,
                          onSubmitted: (_) => onAddCustom(),
                          style: SpeakrText.sans(size: 12),
                          decoration: const InputDecoration(
                            hintText: 'New tag…',
                            isDense: true,
                            filled: false,
                            contentPadding: EdgeInsets.symmetric(vertical: 6),
                            border: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: SpeakrColors.line),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: SpeakrColors.line),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: SpeakrColors.ink),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: onAddCustom,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: SpeakrColors.line),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const MonoEyebrow('Add',
                              size: 9, color: SpeakrColors.ink),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.child, required this.onTap});
  final String child;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: SpeakrColors.line),
        ),
        alignment: Alignment.center,
        child: Text(
          child,
          style: SpeakrText.serif(size: 18, weight: FontWeight.w300, height: 1),
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.paused,
    required this.busy,
    required this.onTogglePause,
    required this.onStop,
  });
  final bool paused;
  final bool busy;
  final VoidCallback? onTogglePause;
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _GhostCircle(child: const SpeakrIconView(SpeakrIcon.flagBookmark)),
          GestureDetector(
            onTap: onTogglePause,
            child: Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: SpeakrColors.ink,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Center(
                child: SpeakrIconView(
                  paused ? SpeakrIcon.play : SpeakrIcon.pause,
                  size: 28,
                  color: SpeakrColors.bg,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: busy ? null : onStop,
            child: _GhostCircle(
              child: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: SpeakrColors.ink,
                      ),
                    )
                  : const SpeakrIconView(SpeakrIcon.stop),
            ),
          ),
        ],
      ),
    );
  }
}

class _GhostCircle extends StatelessWidget {
  const _GhostCircle({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: SpeakrColors.line),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
