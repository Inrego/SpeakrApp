import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/credentials_store.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/speakr_icons.dart';

/// Split-screen onboarding: art column on the left, copy + form on the right.
/// 3 slides — intro · self-hosted pitch · connect form. Step 3 connects to
/// the server and persists credentials.
class OnboardingDesktopScreen extends ConsumerStatefulWidget {
  const OnboardingDesktopScreen({super.key});
  @override
  ConsumerState<OnboardingDesktopScreen> createState() =>
      _OnboardingDesktopScreenState();
}

class _OnboardingDesktopScreenState
    extends ConsumerState<OnboardingDesktopScreen> {
  int _step = 0;
  final _urlCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  bool _connecting = false;
  String? _error;

  static const _slides = [
    _SlideCopy(
      eyebrow: 'Minutes for Speakr',
      headLeading: 'The quiet way to ',
      headEm: 'capture',
      headTrailing: ' a meeting.',
      sub:
          "Hit record. We'll handle the transcript, the summary, and the search.",
      art: _Art.wave,
    ),
    _SlideCopy(
      eyebrow: 'Self-hosted',
      headLeading: 'Your audio. ',
      headEm: 'Your server.',
      headTrailing: '',
      sub:
          'Speakr runs on your own machine. Recordings never leave the box you point it at.',
      art: _Art.server,
    ),
    _SlideCopy(
      eyebrow: 'Get started',
      headLeading: "Let's connect to ",
      headEm: 'your Speakr.',
      headTrailing: '',
      sub: 'Paste your server URL and an API token from Settings → API Tokens.',
      art: _Art.form,
    ),
  ];

  @override
  void dispose() {
    _urlCtrl.dispose();
    _tokenCtrl.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final url = _urlCtrl.text.trim();
    final token = _tokenCtrl.text.trim();
    if (url.isEmpty || token.isEmpty) {
      setState(() => _error = 'Server URL and API token are required.');
      return;
    }
    final normalizedUrl = url.endsWith('/')
        ? url.substring(0, url.length - 1)
        : url;
    setState(() {
      _connecting = true;
      _error = null;
    });

    final probeDio =
        Dio(
            BaseOptions(
              baseUrl: '$normalizedUrl/api/v1',
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 12),
            ),
          )
          ..options.headers['X-API-Token'] = token
          ..options.headers['Authorization'] = 'Bearer $token'
          ..options.headers['Accept'] = 'application/json';
    try {
      await probeDio.get<dynamic>('/stats', queryParameters: {'scope': 'user'});
      await ref
          .read(credentialsStoreProvider)
          .write(SpeakrCredentials(baseUrl: normalizedUrl, token: token));
      ref.invalidate(currentCredentialsProvider);
      if (!mounted) return;
      context.go('/library');
    } on DioException catch (e) {
      String msg;
      final code = e.response?.statusCode;
      if (code == 401 || code == 403) {
        msg = 'Token rejected by the server (HTTP $code).';
      } else if (code != null) {
        msg = 'Server replied with HTTP $code.';
      } else {
        msg = 'Could not reach $normalizedUrl. Check the URL and network.';
      }
      if (!mounted) return;
      setState(() => _error = msg);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Unexpected error: $e');
    } finally {
      probeDio.close(force: true);
      if (mounted) setState(() => _connecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_step];
    return Scaffold(
      backgroundColor: SpeakrColors.bg,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Art column (1.1 fr) — fixed background, progress dots, art, step count
          Expanded(
            flex: 11,
            child: Container(
              color: SpeakrColors.bgAlt,
              padding: const EdgeInsets.fromLTRB(60, 60, 60, 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(_slides.length, (i) {
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                            right: i == _slides.length - 1 ? 0 : 6,
                          ),
                          height: 2,
                          decoration: BoxDecoration(
                            color: i <= _step
                                ? SpeakrColors.ink
                                : SpeakrColors.line,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                  Expanded(child: Center(child: _renderArt(slide.art))),
                  Text(
                    '${_step + 1} / ${_slides.length}',
                    style: SpeakrText.mono(
                      size: 10,
                      color: SpeakrColors.muted,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Copy column (1 fr) — eyebrow, h1, sub, error, Back + Continue
          Expanded(
            flex: 10,
            child: Container(
              padding: const EdgeInsets.fromLTRB(70, 60, 70, 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slide.eyebrow.toUpperCase(),
                    style: SpeakrText.mono(
                      size: 11,
                      color: SpeakrColors.muted,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  RichText(
                    text: TextSpan(
                      style: SpeakrText.serif(
                        size: 48,
                        height: 1.1,
                        weight: FontWeight.w400,
                      ),
                      children: [
                        TextSpan(text: slide.headLeading),
                        TextSpan(
                          text: slide.headEm,
                          style: SpeakrText.serif(
                            size: 48,
                            height: 1.1,
                            weight: FontWeight.w400,
                            style: FontStyle.italic,
                          ),
                        ),
                        if (slide.headTrailing.isNotEmpty)
                          TextSpan(text: slide.headTrailing),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Text(
                      slide.sub,
                      style: SpeakrText.sans(
                        size: 16,
                        height: 1.55,
                        color: SpeakrColors.ink2,
                      ),
                    ),
                  ),
                  if (_step == 2) ...[
                    const SizedBox(height: 30),
                    _ConnectForm(
                      urlCtrl: _urlCtrl,
                      tokenCtrl: _tokenCtrl,
                      onSubmit: _connect,
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(maxWidth: 440),
                      decoration: BoxDecoration(
                        color: SpeakrColors.danger.withValues(alpha: 0.06),
                        border: Border.all(
                          color: SpeakrColors.danger.withValues(alpha: 0.4),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _error!,
                        style: SpeakrText.sans(
                          size: 13,
                          color: SpeakrColors.danger,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      _BackButton(
                        visible: _step > 0,
                        onTap: _step > 0 ? () => setState(() => _step--) : null,
                      ),
                      const SizedBox(width: 12),
                      _ContinueButton(
                        connecting: _connecting,
                        label: _step < 2 ? 'Continue' : 'Connect to server',
                        onTap: _connecting
                            ? null
                            : () {
                                if (_step < 2) {
                                  setState(() => _step++);
                                } else {
                                  _connect();
                                }
                              },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderArt(_Art kind) {
    switch (kind) {
      case _Art.wave:
        return SizedBox(
          width: 420,
          height: 200,
          child: CustomPaint(painter: _WaveArtPainter()),
        );
      case _Art.server:
        return SizedBox(
          width: 260,
          height: 260,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: SpeakrColors.bg,
                  border: Border.all(color: SpeakrColors.line),
                  shape: BoxShape.circle,
                ),
              ),
              Positioned(
                top: 40,
                child: Text(
                  'localhost:8080',
                  style: SpeakrText.mono(
                    size: 11,
                    color: SpeakrColors.muted,
                    letterSpacing: 0,
                  ),
                ),
              ),
              CustomPaint(
                size: const Size(100, 100),
                painter: _ServerStackPainter(),
              ),
            ],
          ),
        );
      case _Art.form:
        return SizedBox(
          width: 360,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SERVER URL',
                style: SpeakrText.mono(
                  size: 11,
                  color: SpeakrColors.muted,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: SpeakrColors.bg,
                  border: Border.all(color: SpeakrColors.line),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  _urlCtrl.text.isEmpty
                      ? 'https://speakr.local'
                      : _urlCtrl.text,
                  style: SpeakrText.mono(
                    size: 14,
                    color: SpeakrColors.ink2,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'API TOKEN',
                style: SpeakrText.mono(
                  size: 11,
                  color: SpeakrColors.muted,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: SpeakrColors.bg,
                  border: Border.all(color: SpeakrColors.ink),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  _tokenCtrl.text.isEmpty
                      ? '••••••••••••••••••'
                      : '•' * _tokenCtrl.text.length,
                  style: SpeakrText.mono(
                    size: 14,
                    color: SpeakrColors.ink,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}

enum _Art { wave, server, form }

class _SlideCopy {
  const _SlideCopy({
    required this.eyebrow,
    required this.headLeading,
    required this.headEm,
    required this.headTrailing,
    required this.sub,
    required this.art,
  });
  final String eyebrow;
  final String headLeading;
  final String headEm;
  final String headTrailing;
  final String sub;
  final _Art art;
}

class _ConnectForm extends StatelessWidget {
  const _ConnectForm({
    required this.urlCtrl,
    required this.tokenCtrl,
    required this.onSubmit,
  });
  final TextEditingController urlCtrl;
  final TextEditingController tokenCtrl;
  final VoidCallback onSubmit;
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SERVER URL',
            style: SpeakrText.mono(
              size: 11,
              color: SpeakrColors.muted,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: urlCtrl,
            autocorrect: false,
            keyboardType: TextInputType.url,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
            style: SpeakrText.mono(
              size: 14,
              color: SpeakrColors.ink2,
              letterSpacing: 0,
              weight: FontWeight.w400,
            ),
            decoration: const InputDecoration(
              hintText: 'https://speakr.local',
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'API TOKEN',
            style: SpeakrText.mono(
              size: 11,
              color: SpeakrColors.muted,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: tokenCtrl,
            autocorrect: false,
            obscureText: true,
            style: SpeakrText.mono(
              size: 14,
              color: SpeakrColors.ink,
              letterSpacing: 0,
              weight: FontWeight.w400,
            ),
            decoration: const InputDecoration(
              hintText: '••••••••••••••••••••',
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
            onSubmitted: (_) => onSubmit(),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.visible, this.onTap});
  final bool visible;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: visible ? onTap : null,
      style: TextButton.styleFrom(
        foregroundColor: visible ? SpeakrColors.ink2 : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      child: const Text('Back'),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({
    required this.connecting,
    required this.label,
    required this.onTap,
  });
  final bool connecting;
  final String label;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: SpeakrColors.ink,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          alignment: Alignment.center,
          child: connecting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: SpeakrColors.bg,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: SpeakrText.sans(
                        size: 13,
                        weight: FontWeight.w500,
                        color: SpeakrColors.bg,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const SpeakrIconView(
                      SpeakrIcon.chev,
                      size: 16,
                      color: SpeakrColors.bg,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _WaveArtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = SpeakrColors.ink.withValues(alpha: 0.85);
    const count = 64;
    for (var i = 0; i < count; i++) {
      final h =
          8 +
          (i % 2 == 0 ? 1 : 0.8) *
              (90 + (i % 5) * 6).abs() *
              (0.5 + 0.5 * (1 - (i - count / 2).abs() / (count / 2)));
      final x = i * 6.3 + 4;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height / 2 - h / 2, 3, h),
          const Radius.circular(1.5),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ServerStackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = SpeakrColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final scale = size.width / 80.0;
    canvas.scale(scale);
    for (var i = 0; i < 3; i++) {
      final rect = Rect.fromLTWH(14, 18.0 + i * 18, 52, 14);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        stroke,
      );
      canvas.drawCircle(
        Offset(20, 25.0 + i * 18),
        1.5,
        Paint()..color = i == 2 ? const Color(0xFF3DDC97) : SpeakrColors.ink,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
