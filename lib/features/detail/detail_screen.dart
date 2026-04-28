import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

import '../../api/models.dart';
import '../../services/credentials_store.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../utils/formatters.dart';
import '../../widgets/mono_eyebrow.dart';
import '../../widgets/speakr_icons.dart';
import '../../widgets/tag_chip.dart';
import 'detail_controller.dart';
import 'tabs/chat_tab.dart';
import 'tabs/summary_tab.dart';
import 'tabs/transcript_tab.dart';

class DetailScreen extends ConsumerStatefulWidget {
  const DetailScreen({super.key, required this.recordingId});
  final int recordingId;

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  int _tab = 0;
  final _audioPlayer = AudioPlayer();
  bool _audioReady = false;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    final creds = await ref.read(credentialsStoreProvider).read();
    if (creds == null) return;
    final url =
        '${creds.baseUrl}/api/v1/recordings/${widget.recordingId}/audio';
    try {
      await _audioPlayer.setUrl(
        url,
        headers: {'X-API-Token': creds.token},
      );
      if (mounted) setState(() => _audioReady = true);
    } catch (_) {
      // Audio fails silently — UI still renders summary/transcript/chat.
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncR = ref.watch(recordingDetailProvider(widget.recordingId));
    return Scaffold(
      backgroundColor: SpeakrColors.bg,
      body: SafeArea(
        bottom: false,
        child: asyncR.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
                color: SpeakrColors.ink, strokeWidth: 2),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopBar(date: '', onBack: () => context.pop()),
                const SizedBox(height: 12),
                const MonoEyebrow('Couldn’t load recording'),
                const SizedBox(height: 8),
                Text(e.toString(), style: SpeakrText.sans(size: 14)),
              ],
            ),
          ),
          data: (r) => _DetailBody(
            recording: r,
            tab: _tab,
            onTabChanged: (i) => setState(() => _tab = i),
            audioPlayer: _audioPlayer,
            audioReady: _audioReady,
          ),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.recording,
    required this.tab,
    required this.onTabChanged,
    required this.audioPlayer,
    required this.audioReady,
  });
  final Recording recording;
  final int tab;
  final ValueChanged<int> onTabChanged;
  final AudioPlayer audioPlayer;
  final bool audioReady;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TopBar(
          date: formatRelativeDay(recording.meetingDate ??
              recording.createdAt ??
              DateTime.now()),
          onBack: () => context.pop(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recording.tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children:
                        recording.tags.map((t) => TagChip(tag: t)).toList(),
                  ),
                ),
              Text(
                recording.title?.isNotEmpty == true
                    ? recording.title!
                    : 'Untitled recording',
                style: SpeakrText.serif(size: 26, height: 1.15),
              ),
              if ((recording.participants ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  recording.participants!,
                  style:
                      SpeakrText.sans(size: 12, color: SpeakrColors.muted),
                ),
              ],
            ],
          ),
        ),
        _AudioPlayerBar(
          player: audioPlayer,
          ready: audioReady,
          totalLabel: formatDuration(recording.audioDuration ?? 0),
        ),
        _TabBar(tab: tab, onChanged: onTabChanged),
        Expanded(
          child: IndexedStack(
            index: tab,
            children: [
              SummaryTab(recordingId: recording.id),
              TranscriptTab(recordingId: recording.id),
              ChatTab(recordingId: recording.id),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.date,
    required this.onBack,
  });
  final String date;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          GhostIconButton(icon: SpeakrIcon.back, onTap: onBack),
          Expanded(
            child: Center(
              child: MonoEyebrow(date, size: 10),
            ),
          ),
          GhostIconButton(icon: SpeakrIcon.more, onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: SpeakrColors.bg,
              builder: (_) => const _MoreSheet(),
            );
          }),
        ],
      ),
    );
  }
}

class _MoreSheet extends StatelessWidget {
  const _MoreSheet();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const SpeakrIconView(SpeakrIcon.star),
              title: Text('Toggle highlight',
                  style: SpeakrText.sans(size: 14)),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const SpeakrIconView(SpeakrIcon.flag),
              title: Text('Move to inbox', style: SpeakrText.sans(size: 14)),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioPlayerBar extends StatelessWidget {
  const _AudioPlayerBar({
    required this.player,
    required this.ready,
    required this.totalLabel,
  });
  final AudioPlayer player;
  final bool ready;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: SpeakrColors.bgAlt,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          StreamBuilder<PlayerState>(
            stream: player.playerStateStream,
            builder: (context, snap) {
              final playing = snap.data?.playing ?? false;
              return InkWell(
                customBorder: const CircleBorder(),
                onTap: !ready
                    ? null
                    : () => playing ? player.pause() : player.play(),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ready
                        ? SpeakrColors.ink
                        : SpeakrColors.muted.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: SpeakrIconView(
                    playing ? SpeakrIcon.pause : SpeakrIcon.play,
                    size: 16,
                    color: SpeakrColors.bg,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 14),
          Expanded(
            child: StreamBuilder<Duration>(
              stream: player.positionStream,
              builder: (context, posSnap) {
                final pos = posSnap.data ?? Duration.zero;
                final dur = player.duration ?? Duration.zero;
                final progress = dur.inMilliseconds == 0
                    ? 0.0
                    : (pos.inMilliseconds / dur.inMilliseconds)
                        .clamp(0.0, 1.0)
                        .toDouble();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: SpeakrColors.line,
                          valueColor: const AlwaysStoppedAnimation(
                              SpeakrColors.ink),
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatDuration(pos.inMilliseconds / 1000.0),
                          style: SpeakrText.mono(
                              size: 10,
                              color: SpeakrColors.muted,
                              letterSpacing: 0),
                        ),
                        Text(
                          dur.inMilliseconds > 0
                              ? formatDuration(dur.inMilliseconds / 1000.0)
                              : totalLabel,
                          style: SpeakrText.mono(
                              size: 10,
                              color: SpeakrColors.muted,
                              letterSpacing: 0),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.tab, required this.onChanged});
  final int tab;
  final ValueChanged<int> onChanged;
  static const _labels = ['Summary', 'Transcript', 'Chat'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border.symmetric(
            horizontal: BorderSide(color: SpeakrColors.line)),
      ),
      child: Row(
        children: List.generate(_labels.length, (i) {
          final selected = i == tab;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(i),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected
                          ? SpeakrColors.ink
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 1),
                      child: Text(
                        _labels[i],
                        style: SpeakrText.sans(
                          size: 13,
                          weight: FontWeight.w500,
                          color: selected
                              ? SpeakrColors.ink
                              : SpeakrColors.muted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

