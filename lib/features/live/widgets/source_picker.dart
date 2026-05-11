import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../../../theme/typography.dart';
import '../../../widgets/mono_eyebrow.dart';
import '../../../widgets/speakr_icons.dart';

/// Two-row card that lets the user pick which audio sources are mixed
/// into the live recording. Sits between the timer and the metadata
/// card on the live screen, and inside the mini-window in `compact`
/// mode. Each row toggles immediately — the recording controller's
/// `setMicEnabled` / `setSystemEnabled` propagate the change to the
/// native recorder, which gates the corresponding stream into silence
/// without restarting.
class SourcePicker extends StatelessWidget {
  const SourcePicker({
    super.key,
    required this.micEnabled,
    required this.systemEnabled,
    required this.systemAudioSupported,
    required this.micPending,
    required this.systemPending,
    required this.onMicChanged,
    required this.onSystemChanged,
    this.compact = false,
  });

  final bool micEnabled;
  final bool systemEnabled;
  final bool systemAudioSupported;
  final bool micPending;
  final bool systemPending;
  final ValueChanged<bool> onMicChanged;
  final ValueChanged<bool> onSystemChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final hMargin = compact ? 12.0 : 20.0;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: hMargin),
      decoration: BoxDecoration(
        border: Border.all(color: SpeakrColors.line),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          _SourceRow(
            icon: SpeakrIcon.mic,
            label: 'Microphone',
            enabled: micEnabled,
            available: true,
            pending: micPending,
            unsupportedHint: null,
            onChanged: onMicChanged,
            compact: compact,
          ),
          const Divider(color: SpeakrColors.line, thickness: 1, height: 1),
          _SourceRow(
            icon: SpeakrIcon.speaker,
            label: 'System audio',
            enabled: systemEnabled,
            available: systemAudioSupported,
            pending: systemPending,
            unsupportedHint: 'Windows or Android 10+ only',
            onChanged: onSystemChanged,
            compact: compact,
          ),
        ],
      ),
    );
  }
}

class _SourceRow extends StatelessWidget {
  const _SourceRow({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.available,
    required this.pending,
    required this.unsupportedHint,
    required this.onChanged,
    required this.compact,
  });

  final SpeakrIcon icon;
  final String label;
  final bool enabled;
  final bool available;
  final bool pending;
  final String? unsupportedHint;
  final ValueChanged<bool> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final hPad = compact ? 12.0 : 16.0;
    final vPad = compact ? 10.0 : 12.0;
    final sub = _subline();
    final subColor = !available ? SpeakrColors.muted : SpeakrColors.muted;
    final iconColor = !available
        ? SpeakrColors.muted
        : (enabled ? SpeakrColors.recordingDot : SpeakrColors.ink2);
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, vPad, hPad, vPad),
      child: Row(
        children: [
          SizedBox(
            width: compact ? 18 : 22,
            height: compact ? 18 : 22,
            child: SpeakrIconView(
              icon,
              size: compact ? 18 : 22,
              color: iconColor,
            ),
          ),
          SizedBox(width: compact ? 10 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MonoEyebrow(label, size: compact ? 9 : 10),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: SpeakrText.sans(
                    size: compact ? 10 : 11,
                    color: subColor,
                    weight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (pending)
            SizedBox(
              width: compact ? 18 : 20,
              height: compact ? 18 : 20,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: SpeakrColors.ink,
              ),
            )
          else
            Transform.scale(
              scale: compact ? 0.8 : 0.9,
              child: Switch(
                value: enabled,
                onChanged: available ? onChanged : null,
                activeThumbColor: SpeakrColors.bg,
                activeTrackColor: SpeakrColors.recordingDot,
                inactiveThumbColor: SpeakrColors.bg,
                inactiveTrackColor: SpeakrColors.line,
                trackOutlineColor:
                    WidgetStateProperty.all(SpeakrColors.line),
                materialTapTargetSize:
                    MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
      ),
    );
  }

  String _subline() {
    if (!available) return unsupportedHint ?? 'Unavailable';
    if (pending) return 'Working…';
    return enabled ? 'Recording' : 'Off';
  }
}
