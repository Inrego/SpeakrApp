import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'routing/router.dart';
import 'services/credentials_store.dart';
import 'theme/colors.dart';
import 'theme/typography.dart';

class SpeakrApp extends ConsumerWidget {
  const SpeakrApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Wait for the credentials provider to resolve so the router can
    // pick the correct initial location (library vs onboarding).
    final asyncCreds = ref.watch(currentCredentialsProvider);
    return asyncCreds.when(
      loading: () => const _Splash(),
      error: (_, __) => const _Splash(),
      data: (_) {
        final router = ref.watch(routerProvider);
        return MaterialApp.router(
          title: 'Speakr',
          debugShowCheckedModeBanner: false,
          theme: buildSpeakrTheme(),
          routerConfig: router,
        );
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildSpeakrTheme(),
      home: const Scaffold(
        backgroundColor: SpeakrColors.bg,
        body: SizedBox.shrink(),
      ),
    );
  }
}
