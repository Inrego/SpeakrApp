import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/models.dart';
import '../../features/library/library_controller.dart';
import '../../features/live/live_controller.dart';
import '../../features/live/recording_state.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/speakr_icons.dart';

class LiveDesktopScreen extends ConsumerStatefulWidget {
  const LiveDesktopScreen({super.key});

  @override
  ConsumerState<LiveDesktopScreen> createState() => _LiveDesktopScreenState();
}

class _LiveDesktopScreenState extends ConsumerState<LiveDesktopScreen> {
  StreamSubscription<RecordingNav>? _navSub;
  final _titleCtrl = TextEditingController();
  bool _confirmDiscard = false;

  @override
  void initState() {
    super.initState();
    final controller = ref.read(recordingControllerProvider.notifier);
    _navSub = controller.navStream.listen(_onNav);
    final state = ref.read(recordingControllerProvider);
    if (!state.started && !state.uploading) {
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
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recordingControllerProvider);
    final controller = ref.read(recordingControllerProvider.notifier);
    final canOpenMini =
        !kIsWeb && Platform.isWindows && state.started && !state.miniOpen;

    return Scaffold(
      backgroundColor: SpeakrColors.bg,
      body: Stack(
        children: [
          Column(
            children: [
              _TopBar(
                paused: state.paused,
                onCancel: () => setState(() => _confirmDiscard = true),
                onShowMini: canOpenMini ? controller.openMini : null,
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 14,
                      child: _LeftPane(
                        state: state,
                        controller: controller,
                        titleCtrl: _titleCtrl,
                        onDiscard: () => setState(() => _confirmDiscard = true),
                      ),
                    ),
                    Container(
                      width: 340,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F1EC),
                        border: Border(
                          left: BorderSide(color: SpeakrColors.line),
                        ),
                      ),
                      child: _CapturePanel(
                        state: state,
                        controller: controller,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_confirmDiscard)
            _DiscardOverlay(
              elapsedLabel: state.formattedElapsed,
              onCancel: () => setState(() => _confirmDiscard = false),
              onConfirm: () async {
                setState(() => _confirmDiscard = false);
                await controller.cancel();
              },
            ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.paused,
    required this.onCancel,
    this.onShowMini,
  });
  final bool paused;
  final VoidCallback onCancel;
  final VoidCallback? onShowMini;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: SpeakrColors.line)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _BorderButton(
            label: 'Cancel',
            leading: const Icon(
              Icons.close,
              size: 12,
              color: SpeakrColors.ink2,
            ),
            onTap: onCancel,
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PulseDot(paused: paused),
              const SizedBox(width: 8),
              Text(
                paused ? 'PAUSED' : 'RECORDING',
                style: SpeakrText.mono(
                  size: 11,
                  color: SpeakrColors.recordingDot,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (onShowMini != null)
            _BorderButton(
              label: 'Mini window',
              leading: const SpeakrIconView(
                SpeakrIcon.pip,
                size: 14,
                color: SpeakrColors.ink2,
              ),
              onTap: onShowMini!,
            )
          else
            const SizedBox(width: 110),
        ],
      ),
    );
  }
}

class _BorderButton extends StatelessWidget {
  const _BorderButton({required this.label, required this.onTap, this.leading});
  final String label;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: SpeakrColors.line),
        borderRadius: BorderRadius.circular(5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: onTap,
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 6)],
              Text(
                label,
                style: SpeakrText.sans(size: 12, color: SpeakrColors.ink2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.paused});
  final bool paused;
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Opacity(
        opacity: widget.paused ? 0.5 : 0.3 + 0.7 * (1 - _c.value),
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: SpeakrColors.recordingDot,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// LEFT pane — title, big timer, scrolling waveform, controls
// ─────────────────────────────────────────────────────────

class _LeftPane extends StatelessWidget {
  const _LeftPane({
    required this.state,
    required this.controller,
    required this.titleCtrl,
    required this.onDiscard,
  });
  final RecordingState state;
  final RecordingController controller;
  final TextEditingController titleCtrl;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final started = state.started;
    final paused = state.paused;
    final uploading = state.uploading;

    return Padding(
      padding: const EdgeInsets.fromLTRB(60, 50, 60, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TITLE',
            style: SpeakrText.mono(
              size: 10,
              color: SpeakrColors.muted,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: titleCtrl,
            style: SpeakrText.serif(size: 32, weight: FontWeight.w400),
            decoration: InputDecoration(
              filled: false,
              isDense: true,
              hintText: 'Untitled recording',
              hintStyle: SpeakrText.serif(size: 32, color: SpeakrColors.muted),
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: SpeakrColors.line),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: SpeakrColors.line),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: SpeakrColors.ink),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You can rename it later. We'll suggest one based on the audio.",
            style: SpeakrText.sans(
              size: 12,
              color: SpeakrColors.muted,
              height: 1.4,
            ).copyWith(fontStyle: FontStyle.italic),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _BigTimer(label: state.formattedElapsed),
                _SourcesLine(mic: state.micEnabled, sys: state.systemEnabled),
                _LiveScrollingWave(paused: paused),
              ],
            ),
          ),
          if (state.error != null) ...[
            Text(
              state.error!,
              style: SpeakrText.sans(size: 13, color: SpeakrColors.danger),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PillBtn(
                label: 'Discard',
                leading: const Icon(
                  Icons.delete_outline,
                  size: 14,
                  color: SpeakrColors.ink,
                ),
                onTap: started && !uploading ? onDiscard : null,
              ),
              const SizedBox(width: 18),
              _BigPauseButton(
                paused: paused,
                onTap: started ? controller.togglePause : null,
              ),
              const SizedBox(width: 18),
              _PillBtn(
                label: 'Stop & save',
                leading: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: SpeakrColors.recordingDot,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                onTap: started && !uploading ? controller.stopAndUpload : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BigTimer extends StatelessWidget {
  const _BigTimer({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: SpeakrText.serif(
          size: 128,
          weight: FontWeight.w300,
          height: 1,
          letterSpacing: -3,
        ),
      ),
    );
  }
}

class _SourcesLine extends StatelessWidget {
  const _SourcesLine({required this.mic, required this.sys});
  final bool mic;
  final bool sys;
  @override
  Widget build(BuildContext context) {
    final src = mic && sys
        ? 'Mic + system'
        : mic
        ? 'Mic only'
        : sys
        ? 'System only'
        : 'No source';
    return Text(
      src.toUpperCase(),
      style: SpeakrText.mono(
        size: 11,
        color: SpeakrColors.muted,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _LiveScrollingWave extends StatefulWidget {
  const _LiveScrollingWave({required this.paused});
  final bool paused;
  @override
  State<_LiveScrollingWave> createState() => _LiveScrollingWaveState();
}

class _LiveScrollingWaveState extends State<_LiveScrollingWave>
    with SingleTickerProviderStateMixin {
  static const _count = 110;
  final List<double> _bars = List<double>.generate(
    _count,
    (i) => 0.2 + (math.sin(i * 0.31).abs() * 0.4),
  );
  late final Ticker _ticker;
  int _tick = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      _tick++;
      if (_tick % 3 == 0) {
        if (mounted) {
          setState(() {
            _bars.removeAt(0);
            final next = widget.paused
                ? 0.04
                : (0.18 +
                      _rand(_tick) *
                          0.78 *
                          (0.5 + 0.5 * (math.sin(_tick * 0.07).abs())));
            _bars.add(next);
          });
        }
      }
    })..start();
  }

  double _rand(int seed) {
    final x = math.sin(seed * 12.9898 + 78.233) * 43758.5453;
    return x - x.floorToDouble();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: CustomPaint(size: Size.infinite, painter: _LiveWavePainter(_bars)),
    );
  }
}

class _LiveWavePainter extends CustomPainter {
  _LiveWavePainter(this.bars);
  final List<double> bars;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bw = w / (bars.length * 1.5);
    final gap = bw * 0.5;
    final paint = Paint()..color = SpeakrColors.ink;
    for (var i = 0; i < bars.length; i++) {
      final v = bars[i];
      final bh = v * h * 0.9;
      final x = i * (bw + gap);
      final y = (h - bh) / 2;
      paint.color = SpeakrColors.ink.withValues(
        alpha: 0.25 + 0.75 * (i / bars.length),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, bw, bh),
          Radius.circular(bw / 2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LiveWavePainter oldDelegate) =>
      !identical(oldDelegate.bars, bars);
}

class _PillBtn extends StatelessWidget {
  const _PillBtn({required this.label, required this.onTap, this.leading});
  final String label;
  final VoidCallback? onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const StadiumBorder(side: BorderSide(color: SpeakrColors.line)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 9)],
              Text(
                label.toUpperCase(),
                style: SpeakrText.mono(
                  size: 11,
                  color: SpeakrColors.ink,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BigPauseButton extends StatelessWidget {
  const _BigPauseButton({required this.paused, required this.onTap});
  final bool paused;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 84,
      child: Material(
        color: SpeakrColors.ink,
        shape: const CircleBorder(),
        elevation: 12,
        shadowColor: SpeakrColors.ink.withValues(alpha: 0.18),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(
            child: SpeakrIconView(
              paused ? SpeakrIcon.play : SpeakrIcon.pause,
              size: 28,
              color: SpeakrColors.bg,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// RIGHT pane — capture panel
// ─────────────────────────────────────────────────────────

class _CapturePanel extends ConsumerWidget {
  const _CapturePanel({required this.state, required this.controller});
  final RecordingState state;
  final RecordingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(tagsProvider).value ?? const <Tag>[];
    final folders = ref.watch(foldersProvider).value ?? const <Folder>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading('Capture'),
          const SizedBox(height: 14),
          _SourceCard(
            label: 'Microphone',
            sub: 'Default device',
            on: state.micEnabled,
            level: state.paused ? 0.05 : 0.72,
            onToggle: () => controller.setMicEnabled(!state.micEnabled),
            disabled: state.micPending,
          ),
          const SizedBox(height: 8),
          _SourceCard(
            label: 'System audio',
            sub: state.systemAudioSupported
                ? 'All apps'
                : 'Not supported on this device',
            on: state.systemEnabled,
            level: state.paused ? 0.03 : 0.34,
            onToggle: state.systemAudioSupported
                ? () => controller.setSystemEnabled(!state.systemEnabled)
                : null,
            disabled: state.systemPending || !state.systemAudioSupported,
          ),
          const SizedBox(height: 22),
          _SectionHeading('Speakers'),
          const SizedBox(height: 8),
          _SpeakerStepper(
            value: state.speakers,
            onMinus: () => controller.setSpeakers(state.speakers - 1),
            onPlus: () => controller.setSpeakers(state.speakers + 1),
          ),
          if (folders.isNotEmpty) ...[
            const SizedBox(height: 22),
            _SectionHeading('Folder'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final f in folders)
                  _FolderChipBtn(
                    folder: f,
                    active: state.folderId == f.id,
                    onTap: () => controller.setFolder(
                      state.folderId == f.id ? null : f.id,
                    ),
                  ),
              ],
            ),
          ],
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 22),
            _SectionHeading('Tags'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final t in tags)
                  _TagChipBtn(
                    tag: t,
                    active: state.activeTags.contains(t.name),
                    onTap: () => controller.toggleTag(t.name),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 30),
          _ShortcutsHint(),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: SpeakrText.mono(
        size: 9.5,
        color: SpeakrColors.muted,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.label,
    required this.sub,
    required this.on,
    required this.level,
    required this.onToggle,
    this.disabled = false,
  });
  final String label;
  final String sub;
  final bool on;
  final double level;
  final VoidCallback? onToggle;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled
          ? 0.5
          : on
          ? 1.0
          : 0.55,
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: disabled ? null : onToggle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: on ? Colors.white : Colors.transparent,
            border: Border.all(
              color: on ? SpeakrColors.line : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: SpeakrText.sans(
                            size: 13,
                            weight: FontWeight.w500,
                            color: SpeakrColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sub,
                          style: SpeakrText.sans(
                            size: 11,
                            color: SpeakrColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _MiniToggle(on: on),
                ],
              ),
              const SizedBox(height: 10),
              _LevelMeter(level: level, on: on),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniToggle extends StatelessWidget {
  const _MiniToggle({required this.on});
  final bool on;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 18,
      decoration: BoxDecoration(
        color: on ? SpeakrColors.ink : SpeakrColors.line,
        borderRadius: BorderRadius.circular(100),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 180),
        alignment: on ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Container(
            width: 14,
            height: 14,
            decoration: const BoxDecoration(
              color: SpeakrColors.bg,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelMeter extends StatelessWidget {
  const _LevelMeter({required this.level, required this.on});
  final double level;
  final bool on;
  @override
  Widget build(BuildContext context) {
    const count = 18;
    final lit = (level * count).clamp(0, count).toInt();
    return SizedBox(
      height: 5,
      child: Row(
        children: List.generate(count, (i) {
          final isLit = on && i < lit;
          final isHot = i > 14;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i == count - 1 ? 0 : 2),
              decoration: BoxDecoration(
                color: isLit
                    ? (isHot ? SpeakrColors.recordingDot : SpeakrColors.ink)
                    : SpeakrColors.line,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _SpeakerStepper extends StatelessWidget {
  const _SpeakerStepper({
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: SpeakrColors.line),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'How many voices?',
              style: SpeakrText.sans(
                size: 12,
                color: SpeakrColors.muted,
              ).copyWith(fontStyle: FontStyle.italic),
            ),
          ),
          _StepButton(label: '−', onTap: onMinus),
          const SizedBox(width: 14),
          SizedBox(
            width: 18,
            child: Center(
              child: Text('$value', style: SpeakrText.serif(size: 20)),
            ),
          ),
          const SizedBox(width: 14),
          _StepButton(label: '+', onTap: onPlus),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: SpeakrColors.bg,
      shape: const CircleBorder(side: BorderSide(color: SpeakrColors.line)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 26,
          height: 26,
          child: Center(
            child: Text(
              label,
              style: SpeakrText.serif(size: 14, weight: FontWeight.w300),
            ),
          ),
        ),
      ),
    );
  }
}

class _FolderChipBtn extends StatelessWidget {
  const _FolderChipBtn({
    required this.folder,
    required this.active,
    required this.onTap,
  });
  final Folder folder;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final c = parseHexColor(folder.color);
    return InkWell(
      borderRadius: BorderRadius.circular(3),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: active ? c : Colors.transparent,
          border: Border.all(color: active ? c : c.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: active ? Colors.white : c,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              folder.name.toUpperCase(),
              style: SpeakrText.mono(
                size: 10,
                color: active ? Colors.white : c,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagChipBtn extends StatelessWidget {
  const _TagChipBtn({
    required this.tag,
    required this.active,
    required this.onTap,
  });
  final Tag tag;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final c = parseHexColor(tag.color);
    return InkWell(
      borderRadius: BorderRadius.circular(3),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active ? c : Colors.transparent,
          border: Border.all(color: active ? c : c.withValues(alpha: 0.33)),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          (active ? tag.name : '+ ${tag.name}').toUpperCase(),
          style: SpeakrText.mono(
            size: 10,
            color: active ? Colors.white : c,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _ShortcutsHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rows = const [
      ['Pause / resume', '⌘ .'],
      ['Stop & save', '⌘ ↩'],
      ['Mark moment', '⌘ M'],
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: SpeakrColors.bg,
        border: Border.all(color: SpeakrColors.line),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: rows
            .mapIndexed(
              (i, row) => Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0 : 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      row[0],
                      style: SpeakrText.sans(
                        size: 11.5,
                        color: SpeakrColors.muted,
                        height: 1.5,
                      ),
                    ),
                    Text(
                      row[1],
                      style: SpeakrText.mono(
                        size: 10,
                        color: SpeakrColors.muted,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Discard overlay
// ─────────────────────────────────────────────────────────

class _DiscardOverlay extends StatelessWidget {
  const _DiscardOverlay({
    required this.elapsedLabel,
    required this.onCancel,
    required this.onConfirm,
  });
  final String elapsedLabel;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onCancel,
        child: Container(
          color: const Color(0x66141210),
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 440,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: SpeakrColors.bg,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    offset: Offset(0, 24),
                    blurRadius: 60,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DISCARD RECORDING',
                    style: SpeakrText.mono(
                      size: 9.5,
                      color: SpeakrColors.recordingDot,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Throw away $elapsedLabel of audio?',
                    style: SpeakrText.serif(size: 22, height: 1.25),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "The recording will be permanently deleted. It won't be transcribed.",
                    style: SpeakrText.sans(
                      size: 13,
                      color: SpeakrColors.muted,
                      height: 1.45,
                    ).copyWith(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _PillBtn(label: 'Keep recording', onTap: onCancel),
                      const SizedBox(width: 8),
                      Material(
                        color: SpeakrColors.recordingDot,
                        shape: const StadiumBorder(),
                        child: InkWell(
                          customBorder: const StadiumBorder(),
                          onTap: onConfirm,
                          child: Container(
                            height: 36,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.center,
                            child: Text(
                              'Discard',
                              style: SpeakrText.sans(
                                size: 13,
                                weight: FontWeight.w500,
                                color: SpeakrColors.bg,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
