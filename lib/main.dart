import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:workmanager/workmanager.dart';

import 'app.dart';
import 'features/auto_upload/auto_upload_worker.dart';
import 'features/auto_upload/workmanager_callback.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    JustAudioMediaKit.ensureInitialized();
  }
  GoogleFonts.config.allowRuntimeFetching = true;

  if (!kIsWeb && Platform.isAndroid) {
    await Workmanager().initialize(autoUploadCallbackDispatcher);
    await Workmanager().registerPeriodicTask(
      AutoUploadTaskNames.periodic,
      AutoUploadTaskNames.periodic,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    // No WorkManager on desktop — run a foreground polling loop. The
    // worker bails internally when the feature is disabled, so this is
    // cheap when not configured.
    Timer.periodic(const Duration(minutes: 5), (_) {
      runAutoUploadScan(trigger: 'desktop_timer');
    });
  }

  // Drop two error-level mpv log lines that media_kit / libmpv emit on every
  // player init — `osc` (video-only property doesn't exist in libmpv) and
  // `lavf: Failed to create file cache` (HTTP stream cache falls back to the
  // 32MB in-memory buffer). media_kit's MPVLogLevel can't be set below `error`,
  // so we filter at the print boundary. Real playback failures still surface
  // via AudioPlayer's error stream.
  runZoned(
    () => runApp(const ProviderScope(child: SpeakrApp())),
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        if (line.startsWith('MPV: [error]')) return;
        parent.print(zone, line);
      },
    ),
  );
}
