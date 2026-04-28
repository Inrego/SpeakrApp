import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../../../theme/typography.dart';
import '../../../widgets/mono_eyebrow.dart';
import '../../../widgets/speakr_icons.dart';
import '../../../widgets/tag_chip.dart';
import '../preset_tags.dart';

class LiveIndicator extends StatefulWidget {
  const LiveIndicator({super.key, required this.paused});
  final bool paused;
  @override
  State<LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<LiveIndicator>
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

class RecordingTimer extends StatelessWidget {
  const RecordingTimer({super.key, required this.text, this.compact = false});
  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          text,
          style: SpeakrText.serif(
            size: compact ? 36 : 56,
            weight: FontWeight.w300,
            height: 1,
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: compact ? 6 : 10),
        MonoEyebrow(
          'New recording · ${_today()}',
          size: compact ? 9 : 11,
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

class MetadataCard extends StatelessWidget {
  const MetadataCard({
    super.key,
    required this.speakers,
    required this.onSpeakersChanged,
    required this.activeTags,
    required this.tagPickerOpen,
    required this.onToggleTag,
    required this.onToggleEdit,
    required this.newTagCtrl,
    required this.onAddCustom,
    this.compact = false,
  });
  final int speakers;
  final ValueChanged<int> onSpeakersChanged;
  final List<String> activeTags;
  final bool tagPickerOpen;
  final ValueChanged<String> onToggleTag;
  final VoidCallback onToggleEdit;
  final TextEditingController newTagCtrl;
  final VoidCallback onAddCustom;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final hPad = compact ? 12.0 : 16.0;
    final vPad = compact ? 10.0 : 12.0;
    final hMargin = compact ? 12.0 : 20.0;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: hMargin),
      decoration: BoxDecoration(
        border: Border.all(color: SpeakrColors.line),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, vPad, hPad, vPad),
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
                SizedBox(width: compact ? 10 : 14),
                SizedBox(
                  width: 22,
                  child: Center(
                    child: Text(
                      '$speakers',
                      style: SpeakrText.serif(size: compact ? 20 : 24, height: 1),
                    ),
                  ),
                ),
                SizedBox(width: compact ? 10 : 14),
                _StepperButton(
                  child: '+',
                  onTap: () =>
                      onSpeakersChanged((speakers + 1).clamp(1, 12)),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(hPad, vPad, hPad, vPad),
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
                            size: 12, color: SpeakrColors.muted),
                      ),
                    for (final name in activeTags)
                      CustomColorTagChip(
                        label: name,
                        color: colorForTag(name),
                        filled: true,
                        onTap: tagPickerOpen ? () => onToggleTag(name) : null,
                        trailing: tagPickerOpen
                            ? Text('×',
                                style: SpeakrText.serif(
                                  size: 11,
                                  color: colorForTag(name)
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
                      for (final t in presetTags)
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

class RecordingControls extends StatelessWidget {
  const RecordingControls({
    super.key,
    required this.paused,
    required this.busy,
    required this.onTogglePause,
    required this.onStop,
    this.compact = false,
  });
  final bool paused;
  final bool busy;
  final VoidCallback? onTogglePause;
  final VoidCallback? onStop;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final mainSize = compact ? 60.0 : 84.0;
    final ghostSize = compact ? 44.0 : 56.0;
    final iconSize = compact ? 22.0 : 28.0;
    final hPad = compact ? 18.0 : 28.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, compact ? 14 : 24, hPad, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _GhostCircle(
            size: ghostSize,
            child: const SpeakrIconView(SpeakrIcon.flagBookmark),
          ),
          GestureDetector(
            onTap: onTogglePause,
            child: Container(
              width: mainSize,
              height: mainSize,
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
                  size: iconSize,
                  color: SpeakrColors.bg,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: busy ? null : onStop,
            child: _GhostCircle(
              size: ghostSize,
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
  const _GhostCircle({required this.child, this.size = 56});
  final Widget child;
  final double size;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: SpeakrColors.line),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
