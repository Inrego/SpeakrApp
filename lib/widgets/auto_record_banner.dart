import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auto_record/auto_record_bootstrap.dart';
import '../services/auto_record/auto_record_coordinator.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

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
