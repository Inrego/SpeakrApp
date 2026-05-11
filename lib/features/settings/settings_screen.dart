import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/models.dart';
import '../../api/providers.dart';
import '../../api/speakr_api.dart';
import '../../services/auto_record/auto_record_providers.dart';
import '../../services/auto_start/auto_start_providers.dart';
import '../../services/credentials_store.dart';
import '../../services/preferences/time_format_preference.dart';
import '../../services/preferences/time_format_providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../utils/formatters.dart';
import '../../widgets/mono_eyebrow.dart';
import '../../widgets/settings_row.dart';
import '../../widgets/speakr_icons.dart';
import '../auto_upload/auto_upload_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _autoSummarize = true;
  bool _serverOk = true;
  bool _checkingServer = false;
  int? _storageBytes;
  int? _recordingsCount;
  String _baseUrl = '';
  String _maskedToken = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final creds = await ref.read(credentialsStoreProvider).read();
    if (creds != null && mounted) {
      setState(() {
        _baseUrl = creds.baseUrl;
        _maskedToken = _maskToken(creds.token);
      });
    }
    setState(() => _checkingServer = true);

    bool reachable = false;
    StatsResponse? stats;
    try {
      stats = await ref.read(speakrApiProvider).getStats();
      reachable = true;
    } on SpeakrApiException catch (e) {
      // A non-null statusCode means the server replied — still reachable.
      // Otherwise the underlying DioException tells us whether the failure
      // was network-level.
      reachable = e.statusCode != null || !_isNetworkFailure(e.cause);
      debugPrint('Settings status: stats call failed: $e');
    } catch (e, st) {
      // Anything else (e.g. type/cast errors from a payload we cannot parse)
      // means we got past the network — treat the server as reachable.
      reachable = true;
      debugPrint('Settings status: stats parse failed: $e\n$st');
    }

    if (!mounted) return;
    setState(() {
      _serverOk = reachable;
      _storageBytes = stats?.storage?.usedBytes;
      _recordingsCount = stats?.recordings?.total;
      _checkingServer = false;
    });
  }

  bool _isNetworkFailure(Object? cause) {
    if (cause is DioException) {
      switch (cause.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
        case DioExceptionType.badCertificate:
          return true;
        case DioExceptionType.cancel:
        case DioExceptionType.badResponse:
        case DioExceptionType.unknown:
          return cause.error is SocketException;
      }
    }
    return cause is SocketException;
  }

  String _maskToken(String t) {
    if (t.length <= 4) return '••••${t}';
    return '••••••••${t.substring(t.length - 4)}';
  }

  Future<void> _signOut() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: SpeakrColors.bg,
        title: Text('Sign out?', style: SpeakrText.serif(size: 20)),
        content: Text(
          'Disconnects from the server and clears stored credentials.',
          style: SpeakrText.sans(size: 14, color: SpeakrColors.ink2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Sign out',
                style: SpeakrText.sans(
                    size: 14, color: SpeakrColors.danger)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(credentialsStoreProvider).clear();
    ref.invalidate(currentCredentialsProvider);
    if (!mounted) return;
    context.go('/onboarding');
  }

  Future<void> _toggleAutoStart(bool v) async {
    try {
      await ref.read(autoStartServiceProvider).setEnabled(v);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update auto-start: $e')),
      );
    } finally {
      ref.invalidate(autoStartEnabledProvider);
    }
  }

  Future<void> _toggleAutoSummarize(bool v) async {
    setState(() => _autoSummarize = v);
    try {
      await ref.read(speakrApiProvider).setAutoSummarization(v);
    } catch (e) {
      if (!mounted) return;
      setState(() => _autoSummarize = !v);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update setting: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpeakrColors.bg,
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  GhostIconButton(
                      icon: SpeakrIcon.back, onTap: () => context.pop()),
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: MonoEyebrow('Settings', size: 10),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: SpeakrColors.ink,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      'ME',
                      style: SpeakrText.serif(size: 22, color: SpeakrColors.bg),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Connected user',
                            style: SpeakrText.serif(size: 20)),
                        const SizedBox(height: 2),
                        Text(
                          _baseUrl.isEmpty ? '—' : _baseUrl,
                          style: SpeakrText.mono(
                              size: 11, color: SpeakrColors.muted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SettingsGroup(
              label: 'Server',
              children: [
                SettingsRow(label: 'Server URL', value: _baseUrl, mono: true),
                SettingsRow(label: 'API Token', value: _maskedToken, mono: true),
                SettingsRow(
                  label: 'Status',
                  value: _checkingServer
                      ? 'Checking…'
                      : (_serverOk ? 'Connected' : 'Unreachable'),
                  valueColor: _checkingServer
                      ? SpeakrColors.muted
                      : (_serverOk
                          ? SpeakrColors.ok
                          : SpeakrColors.danger),
                ),
              ],
            ),
            SettingsGroup(
              label: 'Recording',
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final s = ref.watch(autoRecordSettingsProvider);
                    final settings = s.value;
                    final controller =
                        ref.read(autoRecordSettingsControllerProvider);
                    return SettingsRow(
                      label: 'Record microphone by default',
                      subtitle: 'New sessions start with the mic source on. '
                          'Can be toggled mid-recording.',
                      toggleValue: settings?.defaultMicEnabled ?? true,
                      onToggle: settings == null
                          ? null
                          : controller.setDefaultMicEnabled,
                    );
                  },
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final s = ref.watch(autoRecordSettingsProvider);
                    final settings = s.value;
                    final controller =
                        ref.read(autoRecordSettingsControllerProvider);
                    final supported =
                        Platform.isWindows || Platform.isAndroid;
                    return SettingsRow(
                      label: 'Record system audio by default',
                      subtitle: supported
                          ? 'New sessions start with system (loopback) audio '
                              'on. Can be toggled mid-recording. Captures '
                              'audio from other apps that are playing.'
                          : 'System audio capture is only available on '
                              'Windows and Android 10+.',
                      toggleValue: settings?.defaultSystemEnabled ?? false,
                      onToggle: (supported && settings != null)
                          ? controller.setDefaultSystemEnabled
                          : null,
                    );
                  },
                ),
                SettingsRow(
                  label: 'Auto-summarize',
                  toggleValue: _autoSummarize,
                  onToggle: _toggleAutoSummarize,
                ),
                if (Platform.isWindows)
                  Consumer(
                    builder: (context, ref, _) {
                      final s = ref.watch(autoRecordSettingsProvider);
                      final summary = s.maybeWhen(
                        data: (settings) {
                          if (!settings.enabled) return 'Off';
                          final n = settings.allowlist.length;
                          if (n == 0) return 'On · no apps';
                          return n == 1 ? 'On · 1 app' : 'On · $n apps';
                        },
                        orElse: () => '—',
                      );
                      return SettingsRow(
                        label: 'Auto-record on mic activity',
                        value: summary,
                        onTap: () => context.push('/settings/auto-record'),
                      );
                    },
                  ),
              ],
            ),
            SettingsGroup(
              label: 'Display',
              children: const [_TimeFormatRow()],
            ),
            if (Platform.isWindows)
              Consumer(
                builder: (context, ref, _) {
                  final enabled = ref.watch(autoStartEnabledProvider);
                  return SettingsGroup(
                    label: 'Startup',
                    children: [
                      SettingsRow(
                        label: 'Start with Windows',
                        subtitle:
                            'Launches Speakr minimized to the tray when you sign in.',
                        toggleValue: enabled.maybeWhen(
                          data: (v) => v,
                          orElse: () => false,
                        ),
                        onToggle: enabled.hasValue
                            ? (v) => _toggleAutoStart(v)
                            : null,
                      ),
                    ],
                  );
                },
              ),
            Consumer(
              builder: (context, ref, _) {
                final configs = ref.watch(folderConfigsProvider);
                final summary = configs.maybeWhen(
                  data: (list) {
                    if (list.isEmpty) return 'Disabled';
                    final enabled = list.where((c) => c.enabled).length;
                    final total = list.length;
                    final word = total == 1 ? 'folder' : 'folders';
                    return '$enabled of $total $word enabled';
                  },
                  orElse: () => '—',
                );
                return SettingsGroup(
                  label: 'Auto-upload',
                  children: [
                    SettingsRow(
                      label: 'Auto-upload from folders',
                      value: summary,
                      onTap: () => context.push('/settings/auto-upload'),
                    ),
                  ],
                );
              },
            ),
            SettingsGroup(
              label: 'Storage',
              children: [
                SettingsRow(
                  label: 'Recordings',
                  value: _recordingsCount?.toString() ?? '—',
                ),
                SettingsRow(
                  label: 'Storage used',
                  value: formatBytes(_storageBytes),
                ),
              ],
            ),
            SettingsGroup(
              label: 'About',
              children: const [
                SettingsRow(label: 'App version', value: '0.1.0', mono: true),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _signOut,
                  style: TextButton.styleFrom(
                    foregroundColor: SpeakrColors.danger,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('Sign out'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeFormatRow extends ConsumerWidget {
  const _TimeFormatRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pref = ref.watch(timeFormatPreferenceProvider).asData?.value
        ?? TimeFormatPreference.system;
    final systemUses24 = MediaQuery.alwaysUse24HourFormatOf(context);
    final subtitle = pref == TimeFormatPreference.system
        ? (Platform.isWindows
            ? 'System (Windows always reports 12-hour — pick 24h to override)'
            : 'Following system (currently ${systemUses24 ? '24-hour' : '12-hour'})')
        : null;

    Future<void> select(TimeFormatPreference next) =>
        ref.read(timeFormatControllerProvider).set(next);

    return SettingsRow(
      label: 'Time format',
      subtitle: subtitle,
      trailing: _TimeFormatSegments(value: pref, onChanged: select),
    );
  }
}

class _TimeFormatSegments extends StatelessWidget {
  const _TimeFormatSegments({required this.value, required this.onChanged});
  final TimeFormatPreference value;
  final ValueChanged<TimeFormatPreference> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: SpeakrColors.line),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segment('Auto', TimeFormatPreference.system),
          _segment('12h', TimeFormatPreference.twelveHour),
          _segment('24h', TimeFormatPreference.twentyFourHour),
        ],
      ),
    );
  }

  Widget _segment(String label, TimeFormatPreference pref) {
    final selected = value == pref;
    return GestureDetector(
      onTap: selected ? null : () => onChanged(pref),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? SpeakrColors.ink : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: SpeakrText.mono(
            size: 11,
            color: selected ? SpeakrColors.bg : SpeakrColors.muted,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
