import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/colors.dart';
import '../../../widgets/mono_eyebrow.dart';
import '../../../widgets/speakr_icons.dart';
import '../widgets/recording_widgets.dart';
import 'recording_mirror.dart';

class MiniRecorderScreen extends ConsumerStatefulWidget {
  const MiniRecorderScreen({super.key});

  @override
  ConsumerState<MiniRecorderScreen> createState() => _MiniRecorderScreenState();
}

class _MiniRecorderScreenState extends ConsumerState<MiniRecorderScreen> {
  bool _tagPickerOpen = false;
  final _newTagCtrl = TextEditingController();

  @override
  void dispose() {
    _newTagCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recordingMirrorProvider);
    final mirror = ref.read(recordingMirrorProvider.notifier);

    return Scaffold(
      backgroundColor: SpeakrColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _MiniTopBar(
              onCancel: mirror.cancel,
              onDragStart: mirror.beginDrag,
            ),
            const SizedBox(height: 2),
            LiveIndicator(paused: state.paused),
            const SizedBox(height: 6),
            RecordingTimer(text: state.formattedElapsed, compact: true),
            const SizedBox(height: 10),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  state.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: SpeakrColors.danger,
                    fontSize: 11,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            MetadataCard(
              speakers: state.speakers,
              onSpeakersChanged: mirror.setSpeakers,
              activeTags: state.activeTags,
              tagPickerOpen: _tagPickerOpen,
              onToggleTag: mirror.toggleTag,
              onToggleEdit: () =>
                  setState(() => _tagPickerOpen = !_tagPickerOpen),
              newTagCtrl: _newTagCtrl,
              onAddCustom: () {
                final v = _newTagCtrl.text.trim();
                if (v.isEmpty) return;
                mirror.addCustomTag(v);
                _newTagCtrl.clear();
              },
              compact: true,
            ),
            const Spacer(),
            RecordingControls(
              paused: state.paused,
              busy: state.uploading,
              onTogglePause: state.started ? mirror.togglePause : null,
              onStop: state.started ? mirror.stop : null,
              compact: true,
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}

class _MiniTopBar extends StatelessWidget {
  const _MiniTopBar({
    required this.onCancel,
    required this.onDragStart,
  });
  final VoidCallback onCancel;
  final Future<void> Function() onDragStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SpeakrColors.bg,
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
      child: Row(
        children: [
          GhostIconButton(icon: SpeakrIcon.close, onTap: onCancel),
          Expanded(
            child: _DragRegion(
              onDragStart: onDragStart,
              child: const Center(child: MonoEyebrow('Recording', size: 9)),
            ),
          ),
          _DragRegion(
            onDragStart: onDragStart,
            child: const SizedBox(width: 36, height: 36),
          ),
        ],
      ),
    );
  }
}

class _DragRegion extends StatelessWidget {
  const _DragRegion({required this.onDragStart, required this.child});
  final Future<void> Function() onDragStart;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) {
        if (event.buttons == kPrimaryMouseButton) {
          onDragStart();
        }
      },
      child: child,
    );
  }
}
