import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auto_upload/auto_upload_settings_screen.dart';
import '../features/detail/detail_screen.dart';
import '../features/library/library_screen.dart';
import '../features/live/live_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/settings/settings_screen.dart';
import '../services/credentials_store.dart';
import '../theme/colors.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    redirect: (context, state) {
      // While the FutureProvider resolves, leave wherever the user is and
      // let the SplashGate cover the gap.
      final asyncCreds = ref.read(currentCredentialsProvider);
      if (asyncCreds.isLoading) return null;
      final creds = asyncCreds.value;
      final loc = state.uri.path;
      final atOnboarding = loc == '/onboarding';
      if (creds == null) {
        return atOnboarding ? null : '/onboarding';
      }
      if (atOnboarding || loc == '/') return '/library';
      return null;
    },
    refreshListenable: _CredentialsListenable(ref),
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => '/library',
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/library',
        builder: (_, __) => const LibraryScreen(),
      ),
      GoRoute(
        path: '/recording/:id',
        builder: (_, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return DetailScreen(recordingId: id);
        },
      ),
      GoRoute(
        path: '/live',
        builder: (_, __) => const LiveScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/auto-upload',
        builder: (_, __) => const AutoUploadSettingsScreen(),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      backgroundColor: SpeakrColors.bg,
      body: Center(
        child: Text('Route not found: ${state.uri.path}'),
      ),
    ),
  );
});

class _CredentialsListenable extends ChangeNotifier {
  _CredentialsListenable(this._ref) {
    _ref.listen<AsyncValue<SpeakrCredentials?>>(currentCredentialsProvider,
        (_, __) => notifyListeners());
  }
  final Ref _ref;
}
