import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/colors.dart';
import '../../../theme/typography.dart';
import '../../../widgets/mono_eyebrow.dart';
import '../../../widgets/speakr_icons.dart';
import '../widgets/recording_widgets.dart';
import '../widgets/source_picker.dart';
import 'recording_mirror.dart';

class MiniRecorderScreen extends ConsumerStatefulWidget {
  const MiniRecorderScreen({super.key});

  @override
  ConsumerState<MiniRecorderScreen> createState() => _MiniRecorderScreenState();
}

class _MiniRecorderScreenState extends ConsumerState<MiniRecorderScreen> {
  bool _tagPickerOpen = false;
  bool _folderPickerOpen = false;

  Future<void> _confirmDiscard() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        backgroundColor: SpeakrColors.bg,
        title: Text('Discard recording?', style: SpeakrText.serif(size: 20)),
        content: Text(
          'This will stop the recording and delete the audio. '
          'This cannot be undone.',
          style: SpeakrText.sans(size: 14, color: SpeakrColors.ink2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Keep recording',
              style: SpeakrText.sans(size: 14, color: SpeakrColors.ink),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Discard',
              style: SpeakrText.sans(size: 14, color: SpeakrColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(recordingMirrorProvider.notifier).cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recordingMirrorProvider);
    final mirror = ref.read(recordingMirrorProvider.notifier);
    final tags = ref.watch(miniTagsProvider);
    final folders = ref.watch(miniFoldersProvider);

    return Scaffold(
      backgroundColor: SpeakrColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _MiniTopBar(
              onClose: mirror.hideMini,
              onDiscard: _confirmDiscard,
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
            SourcePicker(
              micEnabled: state.micEnabled,
              systemEnabled: state.systemEnabled,
              systemAudioSupported: state.systemAudioSupported,
              micPending: state.micPending,
              systemPending: state.systemPending,
              onMicChanged: mirror.setMicEnabled,
              onSystemChanged: mirror.setSystemEnabled,
              compact: true,
            ),
            const SizedBox(height: 8),
            MetadataCard(
              speakers: state.speakers,
              onSpeakersChanged: mirror.setSpeakers,
              activeTags: state.activeTags,
              tagPickerOpen: _tagPickerOpen,
              onToggleTag: mirror.toggleTag,
              onToggleEdit: () => setState(() {
                _tagPickerOpen = !_tagPickerOpen;
                // Keep the compact window from growing too tall by ensuring
                // only one picker is open at a time.
                if (_tagPickerOpen) _folderPickerOpen = false;
              }),
              tags: tags,
              folders: folders,
              folderId: state.folderId,
              folderPickerOpen: _folderPickerOpen,
              onToggleFolderEdit: () => setState(() {
                _folderPickerOpen = !_folderPickerOpen;
                if (_folderPickerOpen) _tagPickerOpen = false;
              }),
              onFolderChanged: mirror.setFolder,
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
    required this.onClose,
    required this.onDiscard,
    required this.onDragStart,
  });
  final VoidCallback onClose;
  final Future<void> Function() onDiscard;
  final Future<void> Function() onDragStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SpeakrColors.bg,
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
      child: Row(
        children: [
          GhostIconButton(icon: SpeakrIcon.close, onTap: onClose),
          Expanded(
            child: _DragRegion(
              onDragStart: onDragStart,
              child: const Center(child: MonoEyebrow('Recording', size: 9)),
            ),
          ),
          GhostIconButton(icon: SpeakrIcon.trash, onTap: () => onDiscard()),
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
