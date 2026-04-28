import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/live/live_controller.dart';
import '../features/live/recording_state.dart';
import '../services/auto_record/auto_record_bootstrap.dart';
import '../services/auto_record/auto_record_coordinator.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'mono_eyebrow.dart';

/// Persistent banner shown at the bottom of every screen while an
/// auto-recording session is active. Tapping the banner navigates to
/// `/live`; tapping "Stop" stops and uploads via [RecordingController].
///
/// Wraps [child] so it can be inserted once at the app root in
/// `app.dart`.
class AutoRecordBanner extends ConsumerWidget {
  const AutoRecordBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recordingControllerProvider);
    final coord = ref.watch(autoRecordCoordinatorProvider);
    final showBanner = coord != null &&
        coord.isAutoSession &&
        (state.started || state.uploading);

    return Stack(
      children: [
        Positioned.fill(child: child),
        if (showBanner)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: _Banner(
                state: state,
                triggerLabel: coord.activeTriggerLabel ?? 'Recording',
              ),
            ),
          ),
      ],
    );
  }
}

class _Banner extends ConsumerWidget {
  const _Banner({required this.state, required this.triggerLabel});
  final RecordingState state;
  final String triggerLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elapsed = state.formattedElapsed;
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: SpeakrColors.ink,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => GoRouter.of(context).go('/live'),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
            child: Row(
              children: [
                const _PulsingDot(),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MonoEyebrow(
                        'AUTO-RECORDING · $triggerLabel',
                        size: 9,
                        color: SpeakrColors.recordingDot,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        elapsed,
                        style: SpeakrText.serif(
                          size: 15,
                          color: SpeakrColors.bg,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: state.uploading
                      ? null
                      : () async {
                          final coord =
                              ref.read(autoRecordCoordinatorProvider);
                          if (coord != null) {
                            await coord.stopAutoSession();
                          } else {
                            await ref
                                .read(recordingControllerProvider.notifier)
                                .stopAndUpload();
                          }
                        },
                  style: TextButton.styleFrom(
                    foregroundColor: SpeakrColors.bg,
                  ),
                  child: const Text('Stop'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.4).animate(_ctrl),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: SpeakrColors.recordingDot,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Imperative coordinator that listens to the auto-record prompt stream
/// and shows a non-blocking dialog. Mounted once near the app root.
class AutoRecordPromptListener extends ConsumerStatefulWidget {
  const AutoRecordPromptListener({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<AutoRecordPromptListener> createState() =>
      _AutoRecordPromptListenerState();
}

class _AutoRecordPromptListenerState
    extends ConsumerState<AutoRecordPromptListener> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(autoRecordPromptsProvider, (_, next) {
      next.whenData((req) => _show(req));
    });
    return widget.child;
  }

  Future<void> _show(StopPromptRequest req) async {
    if (_open || !mounted) return;
    final coord = ref.read(autoRecordCoordinatorProvider);
    coord?.notePromptShown();
    _open = true;
    try {
      final keep = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _StopPromptDialog(req: req),
      );
      coord?.notePromptDismissed(keepRecording: keep == true);
      if (keep == false && coord != null) {
        await coord.stopAutoSession();
      }
    } finally {
      _open = false;
    }
  }
}

class _StopPromptDialog extends StatelessWidget {
  const _StopPromptDialog({required this.req});
  final StopPromptRequest req;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: SpeakrColors.bg,
      title: Text('Stop recording?', style: SpeakrText.serif(size: 20)),
      content: Text(
        'Speakr has been auto-recording ${req.triggerLabel} for '
        '${_formatElapsed(req.elapsed)}. The mic was released and audio '
        'has been quiet. Stop and upload now?',
        style: SpeakrText.sans(size: 14, color: SpeakrColors.ink2),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            'Keep recording',
            style: SpeakrText.sans(size: 14, color: SpeakrColors.ink),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Stop',
            style: SpeakrText.sans(size: 14, color: SpeakrColors.danger),
          ),
        ),
      ],
    );
  }

  static String _formatElapsed(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
