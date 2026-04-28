import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/mono_eyebrow.dart';
import '../../widgets/speakr_icons.dart';
import 'live_controller.dart';
import 'widgets/recording_widgets.dart';

class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({super.key});

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen> {
  bool _tagPickerOpen = false;
  final _newTagCtrl = TextEditingController();
  StreamSubscription<RecordingNav>? _navSub;

  @override
  void initState() {
    super.initState();
    final controller = ref.read(recordingControllerProvider.notifier);
    _navSub = controller.navStream.listen(_onNav);
    // Kick off recording on first mount, only if we haven't already
    // started (e.g. user pushed `/live` while recording was running).
    final state = ref.read(recordingControllerProvider);
    if (!state.started && !state.uploading) {
      // Defer to next frame so the navigation transition is settled before
      // the mic permission prompt appears.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.start();
      });
    }
  }

  void _onNav(RecordingNav event) {
    if (!mounted) return;
    switch (event) {
      case RecordingNav.toLibrary:
        context.go('/library');
      case RecordingNav.pop:
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/library');
        }
    }
  }

  @override
  void dispose() {
    _navSub?.cancel();
    _newTagCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recordingControllerProvider);
    final controller = ref.read(recordingControllerProvider.notifier);

    return Scaffold(
      backgroundColor: SpeakrColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onCancel: controller.cancel),
            const SizedBox(height: 4),
            LiveIndicator(paused: state.paused),
            const SizedBox(height: 18),
            RecordingTimer(text: state.formattedElapsed),
            const Spacer(),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  state.error!,
                  style: SpeakrText.sans(size: 13, color: SpeakrColors.danger),
                ),
              ),
            const SizedBox(height: 12),
            MetadataCard(
              speakers: state.speakers,
              onSpeakersChanged: controller.setSpeakers,
              activeTags: state.activeTags,
              tagPickerOpen: _tagPickerOpen,
              onToggleTag: controller.toggleTag,
              onToggleEdit: () =>
                  setState(() => _tagPickerOpen = !_tagPickerOpen),
              newTagCtrl: _newTagCtrl,
              onAddCustom: () {
                final v = _newTagCtrl.text.trim();
                if (v.isEmpty) return;
                controller.addCustomTag(v);
                _newTagCtrl.clear();
              },
            ),
            RecordingControls(
              paused: state.paused,
              busy: state.uploading,
              onTogglePause: state.started ? controller.togglePause : null,
              onStop: state.started ? controller.stopAndUpload : null,
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
  final Future<void> Function() onCancel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GhostIconButton(icon: SpeakrIcon.close, onTap: () => onCancel()),
          const MonoEyebrow('Recording', size: 10),
          const SizedBox(width: 36),
        ],
      ),
    );
  }
}
