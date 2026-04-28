import 'dart:io' show Platform, Process, ProcessException;

import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;

import '../../features/live/mini/mini_window_native.dart';

/// In Flutter debug mode on Windows, rewrite the main window title to
/// `Speakr — <branch>` so simultaneously-running worktree instances are
/// distinguishable in the taskbar. No-op in release builds and on other
/// platforms. Failure is silent — the default native title stays.
Future<void> applyDevBranchTitleIfDebug() async {
  if (!kDebugMode) return;
  if (kIsWeb || !Platform.isWindows) return;

  try {
    final res = Process.runSync(
      'git',
      ['rev-parse', '--abbrev-ref', 'HEAD'],
      runInShell: true,
    );
    if (res.exitCode != 0) return;
    final branch = (res.stdout as String).trim();
    if (branch.isEmpty || branch == 'HEAD') return;
    await MiniWindowNative.setMainWindowTitle('Speakr — $branch');
  } on ProcessException {
    // git not on PATH — leave default title.
  } catch (_) {
    // Anything else is non-fatal; title is cosmetic.
  }
}
