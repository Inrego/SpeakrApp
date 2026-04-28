import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/live/live_controller.dart';
import '../features/live/recording_state.dart';
import '../routing/router.dart';
import '../services/auto_record/auto_record_bootstrap.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'mono_eyebrow.dart';
import 'speakr_icons.dart';

/// Spotify-style mini-player pinned at the bottom of every screen while a
/// recording is active. Tapping the bar re-opens `/live`. The bar is hidden
/// when the user is already on `/live` (the full UI is already visible).
///
/// Wraps [child] so it can be inserted once at the app root in `app.dart`.
class RecordingMiniPlayer extends ConsumerWidget {
  const RecordingMiniPlayer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recordingControllerProvider);
    final coord = ref.watch(autoRecordCoordinatorProvider);
    final isRecording = state.started || state.uploading;
    // We sit above the router in the widget tree (MaterialApp.router
    // builder), so `GoRouter.of(context)` and `GoRouterState.of(context)`
    // are not available. Read the router via Riverpod and listen to the
    // delegate (a ChangeNotifier that fires on push/pop/go) to track the
    // current top-of-stack route.
    final router = ref.watch(routerProvider);
    final delegate = router.routerDelegate;

    return Stack(
      children: [
        Positioned.fill(child: child),
        ListenableBuilder(
          listenable: delegate,
          builder: (context, _) {
            final config = delegate.currentConfiguration;
            final topPath = config.matches.isEmpty
                ? '/'
                : config.matches.last.matchedLocation;
            final onLive = topPath == '/live';
            if (!isRecording || onLive) return const SizedBox.shrink();
            return Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: _Bar(
                  router: router,
                  state: state,
                  isAutoSession: coord?.isAutoSession ?? false,
                  triggerLabel: coord?.activeTriggerLabel,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _Bar extends ConsumerWidget {
  const _Bar({
    required this.router,
    required this.state,
    required this.isAutoSession,
    required this.triggerLabel,
  });

  final GoRouter router;
  final RecordingState state;
  final bool isAutoSession;
  final String? triggerLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(recordingControllerProvider.notifier);
    final coord = ref.read(autoRecordCoordinatorProvider);

    final eyebrow = isAutoSession
        ? 'AUTO-RECORDING · ${triggerLabel ?? 'Recording'}'
        : (state.paused ? 'PAUSED' : 'RECORDING');

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
          onTap: () => router.go('/live'),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
            child: Row(
              children: [
                _PulsingDot(paused: state.paused),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MonoEyebrow(
                        eyebrow,
                        size: 9,
                        color: SpeakrColors.recordingDot,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        state.formattedElapsed,
                        style: SpeakrText.serif(
                          size: 15,
                          color: SpeakrColors.bg,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                _BarIconButton(
                  icon: state.paused ? SpeakrIcon.play : SpeakrIcon.pause,
                  onTap: state.uploading ? null : controller.togglePause,
                ),
                const SizedBox(width: 2),
                _BarIconButton(
                  icon: SpeakrIcon.stop,
                  busy: state.uploading,
                  onTap: state.uploading
                      ? null
                      : () async {
                          if (isAutoSession && coord != null) {
                            await coord.stopAutoSession();
                          } else {
                            await controller.stopAndUpload();
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BarIconButton extends StatelessWidget {
  const _BarIconButton({
    required this.icon,
    this.onTap,
    this.busy = false,
  });

  final SpeakrIcon icon;
  final VoidCallback? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: SpeakrColors.bg,
                  ),
                )
              : SpeakrIconView(icon, size: 18, color: SpeakrColors.bg),
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.paused});

  final bool paused;

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
    final dot = Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: SpeakrColors.recordingDot,
        shape: BoxShape.circle,
      ),
    );
    if (widget.paused) return dot;
    return FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.4).animate(_ctrl),
      child: dot,
    );
  }
}
