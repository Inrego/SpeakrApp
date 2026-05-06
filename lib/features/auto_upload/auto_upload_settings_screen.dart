import 'dart:async';
import 'dart:io' show Platform;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../services/preferences/time_format_preference.dart';
import '../../services/preferences/time_format_providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../utils/formatters.dart';
import '../../widgets/mono_eyebrow.dart';
import '../../widgets/settings_row.dart';
import '../../widgets/speakr_icons.dart';
import '../library/library_controller.dart';
import 'auto_upload_controller.dart';
import 'auto_upload_settings.dart';
import 'auto_upload_worker.dart';
import 'datetime_parser.dart';

// ── List screen ───────────────────────────────────────────────────────────────

class AutoUploadSettingsScreen extends ConsumerStatefulWidget {
  const AutoUploadSettingsScreen({super.key});

  @override
  ConsumerState<AutoUploadSettingsScreen> createState() =>
      _AutoUploadSettingsScreenState();
}

class _AutoUploadSettingsScreenState
    extends ConsumerState<AutoUploadSettingsScreen> {
  bool _scanning = false;
  Timer? _diagnosticsRefreshTimer;

  @override
  void initState() {
    super.initState();
    // The Android PhoneStateReceiver writes breadcrumbs to the same
    // SharedPreferences file as the Dart store, but the Flutter plugin
    // caches values in this isolate's memory and won't pick up cross-
    // isolate writes until reload() is called. Poll the file every 2s
    // while the screen is mounted so the diagnostic rows update live.
    _diagnosticsRefreshTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) async {
        final store = await ref.read(autoUploadStoreProvider.future);
        await store.reload();
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _diagnosticsRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _addFolder() async {
    final picked = await FilePicker.getDirectoryPath();
    if (picked == null || picked.isEmpty) return;
    final entry = await ref
        .read(folderConfigsControllerProvider)
        .addFolder(picked);
    if (!mounted) return;
    _openEditor(entry.id);
  }

  void _openEditor(String configId) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => FolderUploadEditScreen(configId: configId),
      ),
    );
  }

  Future<void> _scanNow() async {
    setState(() => _scanning = true);
    try {
      await runAutoUploadScan(trigger: 'manual');
      ref.invalidate(folderConfigsProvider);
      ref.invalidate(pendingFilesProvider);
      ref.invalidate(pendingFileErrorsProvider);
      ref.invalidate(libraryRecordingsProvider);
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final configsAsync = ref.watch(folderConfigsProvider);
    return Scaffold(
      backgroundColor: SpeakrColors.bg,
      body: SafeArea(
        child: configsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: SpeakrColors.ink),
          ),
          error: (e, _) => Center(child: Text('Could not load settings: $e')),
          data: (configs) {
            final canScan = configs.any((c) => c.enabled && c.hasFolder);
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    children: [
                      GhostIconButton(
                        icon: SpeakrIcon.back,
                        onTap: () => context.pop(),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: MonoEyebrow('Auto-upload', size: 10),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auto-upload from folders',
                        style: SpeakrText.serif(size: 28, height: 1.1),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Watch one or more folders for new audio recordings '
                        'and upload them to Speakr. Each folder has its own '
                        'tag, language, and parsing rules. Files are deleted '
                        'locally once they reach the server.',
                        style: SpeakrText.sans(
                          size: 13,
                          color: SpeakrColors.ink2,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                if (Platform.isAndroid) const _PermissionsBanner(),
                SettingsGroup(
                  label: 'Folders',
                  children: [
                    for (final c in configs)
                      SettingsRow(
                        label: _folderLabel(c),
                        subtitle: c.folderPath,
                        value: c.enabled ? 'On' : 'Off',
                        valueColor: c.enabled
                            ? SpeakrColors.ok
                            : SpeakrColors.muted,
                        mono: false,
                        onTap: () => _openEditor(c.id),
                      ),
                    SettingsRow(
                      label: 'Add folder…',
                      trailing: const Icon(
                        Icons.add,
                        size: 20,
                        color: SpeakrColors.ink,
                      ),
                      onTap: _addFolder,
                    ),
                  ],
                ),
                SettingsGroup(
                  label: 'Run',
                  children: [
                    SettingsRow(
                      label: _scanning ? 'Scanning…' : 'Scan now',
                      trailing: _scanning
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: SpeakrColors.ink,
                              ),
                            )
                          : Icon(
                              Icons.play_arrow_rounded,
                              size: 22,
                              color: canScan
                                  ? SpeakrColors.ink
                                  : SpeakrColors.muted,
                            ),
                      onTap: (canScan && !_scanning) ? _scanNow : null,
                    ),
                    _LastScanRow(),
                  ],
                ),
                if (Platform.isAndroid)
                  SettingsGroup(
                    label: 'Call-end diagnostics',
                    children: const [
                      _LastPhoneStateRow(),
                      _LastPhoneStateDecisionRow(),
                      _LastCallEndEnqueueRow(),
                    ],
                  ),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }

  String _folderLabel(FolderUploadConfig c) {
    if (!c.hasFolder) return 'New folder (no path set)';
    final parts = c.folderPath!.split(RegExp(r'[\\/]'));
    final last = parts.where((s) => s.isNotEmpty).toList();
    return last.isEmpty ? c.folderPath! : last.last;
  }
}

// ── Editor screen ─────────────────────────────────────────────────────────────

class FolderUploadEditScreen extends ConsumerStatefulWidget {
  const FolderUploadEditScreen({super.key, required this.configId});
  final String configId;

  @override
  ConsumerState<FolderUploadEditScreen> createState() =>
      _FolderUploadEditScreenState();
}

class _FolderUploadEditScreenState
    extends ConsumerState<FolderUploadEditScreen> {
  Future<void> _pickFolder() async {
    final picked = await FilePicker.getDirectoryPath();
    if (picked == null || picked.isEmpty) return;
    await ref
        .read(folderConfigsControllerProvider)
        .setFolder(widget.configId, picked);
  }

  Future<void> _typeFolder(FolderUploadConfig current) async {
    final ctrl = TextEditingController(text: current.folderPath ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: SpeakrColors.bg,
        title: Text('Folder path', style: SpeakrText.serif(size: 20)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: SpeakrText.mono(size: 13, color: SpeakrColors.ink),
          decoration: const InputDecoration(
            hintText: '/storage/emulated/0/Recordings/Call',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == null) return;
    await ref
        .read(folderConfigsControllerProvider)
        .setFolder(widget.configId, result.isEmpty ? null : result);
  }

  Future<void> _confirmDelete(FolderUploadConfig config) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: SpeakrColors.bg,
        title: Text('Delete folder?', style: SpeakrText.serif(size: 20)),
        content: Text(
          'Stop watching this folder. Files already on disk are not '
          'touched. You can re-add the folder later.',
          style: SpeakrText.sans(size: 13, color: SpeakrColors.ink2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(folderConfigsControllerProvider).removeFolder(config.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final configsAsync = ref.watch(folderConfigsProvider);
    return Scaffold(
      backgroundColor: SpeakrColors.bg,
      body: SafeArea(
        child: configsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: SpeakrColors.ink),
          ),
          error: (e, _) => Center(child: Text('Could not load settings: $e')),
          data: (configs) {
            FolderUploadConfig? c;
            for (final entry in configs) {
              if (entry.id == widget.configId) {
                c = entry;
                break;
              }
            }
            if (c == null) {
              return const _MissingConfigView();
            }
            final config = c;
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    children: [
                      GhostIconButton(
                        icon: SpeakrIcon.back,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: MonoEyebrow('Folder', size: 10),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.hasFolder
                            ? config.folderPath!
                                  .split(RegExp(r'[\\/]'))
                                  .where((s) => s.isNotEmpty)
                                  .last
                            : 'New folder',
                        style: SpeakrText.serif(size: 24, height: 1.1),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (config.folderPath != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          config.folderPath!,
                          style: SpeakrText.mono(
                            size: 12,
                            color: SpeakrColors.muted,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (Platform.isAndroid) const _PermissionsBanner(),
                SettingsGroup(
                  label: 'Watcher',
                  children: [
                    SettingsRow(
                      label: 'Enabled',
                      toggleValue: config.enabled,
                      onToggle: (v) => ref
                          .read(folderConfigsControllerProvider)
                          .setEnabled(config.id, v),
                    ),
                    SettingsRow(
                      label: 'Folder',
                      value: config.folderPath == null
                          ? 'Not set'
                          : config.folderPath!.split(RegExp(r'[\\/]')).last,
                      subtitle: config.folderPath,
                      mono: false,
                      onTap: _pickFolder,
                    ),
                    SettingsRow(
                      label: 'Type folder path manually',
                      trailing: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: SpeakrColors.muted,
                      ),
                      onTap: () => _typeFolder(config),
                    ),
                  ],
                ),
                SettingsGroup(
                  label: 'Datetime parsing',
                  children: [
                    SettingsRow(
                      label: 'Pattern',
                      value: _parseLabel(config),
                      onTap: () => _showPresetSheet(config),
                    ),
                  ],
                ),
                SettingsGroup(
                  label: 'Defaults applied to uploads',
                  children: [
                    SettingsRow(
                      label: 'Tag',
                      value: _TagLabel.of(ref, config.tagId),
                      onTap: () => _showTagSheet(config),
                    ),
                    SettingsRow(
                      label: 'Language',
                      value: config.language ?? 'auto',
                      onTap: () => _editLanguage(config),
                    ),
                    SettingsRow(
                      label: 'Min speakers',
                      trailing: _Stepper(
                        value: config.minSpeakers ?? 1,
                        min: 1,
                        max: 12,
                        onChanged: (v) => ref
                            .read(folderConfigsControllerProvider)
                            .setMinSpeakers(config.id, v),
                      ),
                    ),
                    SettingsRow(
                      label: 'Max speakers',
                      trailing: _Stepper(
                        value: config.maxSpeakers ?? 1,
                        min: 1,
                        max: 12,
                        onChanged: (v) => ref
                            .read(folderConfigsControllerProvider)
                            .setMaxSpeakers(config.id, v),
                      ),
                    ),
                  ],
                ),
                SettingsGroup(
                  label: 'Filtering',
                  children: [
                    SettingsRow(
                      label: 'Auto-delete shorter than',
                      value: config.autoDeleteShorterThanSeconds == null
                          ? 'Off'
                          : '${config.autoDeleteShorterThanSeconds} s',
                      subtitle:
                          'Recordings under this length are deleted from disk '
                          'instead of being uploaded.',
                      onTap: () => _editAutoDeleteThreshold(config),
                    ),
                  ],
                ),
                SettingsGroup(
                  label: 'Danger zone',
                  children: [
                    SettingsRow(
                      label: 'Delete folder',
                      valueColor: SpeakrColors.danger,
                      trailing: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: SpeakrColors.danger,
                      ),
                      onTap: () => _confirmDelete(config),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }

  String _parseLabel(FolderUploadConfig s) {
    if (s.parsePresetId == null) return 'Off (use file mtime)';
    if (s.parsePresetId == kCustomPresetId) return 'Custom regex';
    return presetById(s.parsePresetId!)?.label ?? 'Off (use file mtime)';
  }

  Future<void> _editLanguage(FolderUploadConfig s) async {
    final ctrl = TextEditingController(text: s.language ?? '');
    final result = await showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: SpeakrColors.bg,
        title: Text('Language', style: SpeakrText.serif(size: 20)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'auto, en, da, …'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == null) return;
    await ref
        .read(folderConfigsControllerProvider)
        .setLanguage(s.id, result.isEmpty ? null : result);
  }

  Future<void> _editAutoDeleteThreshold(FolderUploadConfig s) async {
    final ctrl = TextEditingController(
      text: s.autoDeleteShorterThanSeconds?.toString() ?? '',
    );

    // Three-way result: 'save' with new value (or null = Off), or null = cancel.
    final result = await showDialog<int?>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: SpeakrColors.bg,
        title: Text(
          'Auto-delete shorter than',
          style: SpeakrText.serif(size: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recordings under this many seconds are deleted from disk '
              'instead of being uploaded. Leave blank or set 0 to disable.',
              style: SpeakrText.sans(
                size: 12,
                color: SpeakrColors.ink2,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(),
              decoration: const InputDecoration(
                hintText: 'e.g. 5',
                suffixText: 'seconds',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop<int?>(dialogCtx, 0),
            child: const Text('Off'),
          ),
          TextButton(
            onPressed: () {
              final n = int.tryParse(ctrl.text.trim());
              if (n == null) {
                Navigator.pop<int?>(dialogCtx, 0);
              } else {
                Navigator.pop<int?>(dialogCtx, n);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == null) return; // cancelled
    final value = result <= 0 ? null : result;
    await ref
        .read(folderConfigsControllerProvider)
        .setAutoDeleteShorterThanSeconds(s.id, value);
  }

  Future<void> _showPresetSheet(FolderUploadConfig s) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: SpeakrColors.bg,
      isScrollControlled: true,
      builder: (_) => _PresetSheet(current: s),
    );
  }

  Future<void> _showTagSheet(FolderUploadConfig s) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: SpeakrColors.bg,
      isScrollControlled: true,
      builder: (_) => _TagSheet(configId: s.id, currentId: s.tagId),
    );
  }
}

class _MissingConfigView extends StatelessWidget {
  const _MissingConfigView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GhostIconButton(
                icon: SpeakrIcon.back,
                onTap: () => Navigator.of(context).pop(),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: MonoEyebrow('Folder', size: 10),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 18),
            child: Text(
              'This folder no longer exists.',
              style: SpeakrText.serif(size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Permissions banner ────────────────────────────────────────────────────────

class _PermissionsBanner extends StatefulWidget {
  const _PermissionsBanner();

  @override
  State<_PermissionsBanner> createState() => _PermissionsBannerState();
}

class _PermissionsBannerState extends State<_PermissionsBanner> {
  List<Permission> _missing = const [];
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final wanted = <Permission>[
      Permission.phone,
      Permission.audio,
      Permission.manageExternalStorage,
      Permission.notification,
    ];
    final missing = <Permission>[];
    for (final p in wanted) {
      final status = await p.status;
      if (!status.isGranted) missing.add(p);
    }
    if (mounted) {
      setState(() {
        _missing = missing;
        _checked = true;
      });
    }
  }

  Future<void> _grant() async {
    await _missing.request();
    await _check();
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked || _missing.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 4, 24, 14),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E0),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE8C97A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Permissions needed',
            style: SpeakrText.sans(
              size: 13,
              weight: FontWeight.w600,
              color: SpeakrColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _description(_missing),
            style: SpeakrText.sans(
              size: 12,
              color: SpeakrColors.ink2,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _grant,
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: const Text('Grant permissions'),
            ),
          ),
        ],
      ),
    );
  }

  String _description(List<Permission> missing) {
    final parts = <String>[];
    if (missing.contains(Permission.phone)) {
      parts.add('Phone state — to detect when calls end.');
    }
    if (missing.contains(Permission.audio)) {
      parts.add('Audio files — to read recordings on the device.');
    }
    if (missing.contains(Permission.manageExternalStorage)) {
      parts.add(
        'All files access — to delete recordings after successful upload.',
      );
    }
    if (missing.contains(Permission.notification)) {
      parts.add('Notifications — required for background uploads.');
    }
    return parts.join(' ');
  }
}

// ── Stepper ───────────────────────────────────────────────────────────────────

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 12,
  });
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepperBtn(
          label: '−',
          onTap: value > min ? () => onChanged(value - 1) : null,
        ),
        SizedBox(
          width: 30,
          child: Text(
            value.toString(),
            textAlign: TextAlign.center,
            style: SpeakrText.serif(size: 16),
          ),
        ),
        _StepperBtn(
          label: '+',
          onTap: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}

class _StepperBtn extends StatelessWidget {
  const _StepperBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: SpeakrColors.line),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: SpeakrText.serif(
            size: 16,
            color: onTap == null ? SpeakrColors.muted : SpeakrColors.ink,
            height: 1,
          ),
        ),
      ),
    );
  }
}

// ── Last scan row ─────────────────────────────────────────────────────────────

class _LastScanRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(autoUploadStoreProvider);
    final pref = ref.watch(timeFormatPreferenceProvider).asData?.value
        ?? TimeFormatPreference.system;
    final use24 = resolveUse24Hour(pref, context);
    return storeAsync.maybeWhen(
      data: (store) {
        final at = store.lastScanAt;
        final result = store.lastScanResult;
        // Timestamp goes in `value` (single-line, right-aligned). The
        // trigger/result summary goes in `subtitle` so it can wrap onto
        // multiple lines instead of being clipped with an ellipsis —
        // useful both for normal info ("trigger=… ok=… skipped=…") and
        // for diagnosing why a scan didn't behave as expected.
        return SettingsRow(
          label: 'Last scan',
          value: at == null ? '—' : formatHourMinute(at, use24Hour: use24),
          subtitle: result,
        );
      },
      orElse: () => const SettingsRow(label: 'Last scan', value: '—'),
    );
  }
}

// ── Call-end diagnostic rows ──────────────────────────────────────────────────
//
// These three rows surface breadcrumbs the Android PhoneStateReceiver
// writes on every PHONE_STATE broadcast. They tell us, in order, whether:
//   1. the receiver is firing at all (Last phone-state event),
//   2. the OFFHOOK→IDLE state machine reached the enqueue branch (Last
//      decision),
//   3. WorkManager actually accepted the call-end job (Last call-end
//      enqueue) — compare against "Last scan" above to tell whether the
//      job ran or got deferred by Doze/battery optimization.

class _LastPhoneStateRow extends ConsumerWidget {
  const _LastPhoneStateRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(autoUploadStoreProvider);
    final pref = ref.watch(timeFormatPreferenceProvider).asData?.value
        ?? TimeFormatPreference.system;
    final use24 = resolveUse24Hour(pref, context);
    return storeAsync.maybeWhen(
      data: (store) {
        final at = store.lastPhoneStateAt;
        final state = store.lastPhoneState;
        final prev = store.lastPhoneStatePrevious;
        final subtitle = at == null
            ? 'never — receiver hasn\'t fired since install. '
                'READ_PHONE_STATE may be denied, or the OEM is suppressing '
                'manifest receivers (check OnePlus auto-launch / battery).'
            : 'state=${state ?? '—'} · prev=${prev ?? '—'}';
        return SettingsRow(
          label: 'Last phone-state event',
          value: at == null ? '—' : formatHourMinute(at, use24Hour: use24),
          subtitle: subtitle,
        );
      },
      orElse: () => const SettingsRow(
        label: 'Last phone-state event',
        value: '—',
      ),
    );
  }
}

class _LastPhoneStateDecisionRow extends ConsumerWidget {
  const _LastPhoneStateDecisionRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(autoUploadStoreProvider);
    return storeAsync.maybeWhen(
      data: (store) {
        final decision = store.lastPhoneStateDecision;
        return SettingsRow(
          label: 'Last decision',
          value: decision == null ? '—' : '',
          subtitle: decision,
        );
      },
      orElse: () => const SettingsRow(label: 'Last decision', value: '—'),
    );
  }
}

class _LastCallEndEnqueueRow extends ConsumerWidget {
  const _LastCallEndEnqueueRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(autoUploadStoreProvider);
    final pref = ref.watch(timeFormatPreferenceProvider).asData?.value
        ?? TimeFormatPreference.system;
    final use24 = resolveUse24Hour(pref, context);
    return storeAsync.maybeWhen(
      data: (store) {
        final at = store.lastCallEndEnqueueAt;
        return SettingsRow(
          label: 'Last call-end enqueue',
          value: at == null ? 'never' : formatHourMinute(at, use24Hour: use24),
          subtitle: at == null
              ? 'No OFFHOOK→IDLE transition has reached the enqueue '
                  'branch since install. If "Last phone-state event" '
                  'shows IDLE with prev=null, the app process was killed '
                  'between OFFHOOK and IDLE.'
              : null,
        );
      },
      orElse: () =>
          const SettingsRow(label: 'Last call-end enqueue', value: '—'),
    );
  }
}

// ── Preset sheet ──────────────────────────────────────────────────────────────

class _PresetSheet extends ConsumerStatefulWidget {
  const _PresetSheet({required this.current});
  final FolderUploadConfig current;

  @override
  ConsumerState<_PresetSheet> createState() => _PresetSheetState();
}

class _PresetSheetState extends ConsumerState<_PresetSheet> {
  late String? _selected = widget.current.parsePresetId;
  late final _regex = TextEditingController(
    text: widget.current.customRegex ?? '',
  );
  late final _group = TextEditingController(
    text: (widget.current.customCaptureGroup ?? 1).toString(),
  );
  late final _format = TextEditingController(
    text: widget.current.customFormat ?? '',
  );
  String? _customError;

  @override
  void dispose() {
    _regex.dispose();
    _group.dispose();
    _format.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ctrl = ref.read(folderConfigsControllerProvider);
    final id = widget.current.id;
    if (_selected == null) {
      await ctrl.setPreset(id, null);
    } else if (_selected == kCustomPresetId) {
      final regex = _regex.text.trim();
      final groupStr = _group.text.trim();
      final format = _format.text.trim();
      if (regex.isEmpty || format.isEmpty) {
        setState(() => _customError = 'Regex and format are required.');
        return;
      }
      final group = int.tryParse(groupStr);
      if (group == null || group < 1) {
        setState(
          () => _customError = 'Capture group must be a positive integer.',
        );
        return;
      }
      try {
        RegExp(regex);
      } catch (_) {
        setState(() => _customError = 'Invalid regex syntax.');
        return;
      }
      await ctrl.setCustomParse(
        id: id,
        regex: regex,
        captureGroup: group,
        format: format,
      );
    } else {
      await ctrl.setPreset(id, _selected);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Datetime pattern',
                style: SpeakrText.serif(size: 22),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Parse the recording datetime out of the filename. '
                'Falls back to file modification time if the pattern '
                'doesn\'t match.',
                style: SpeakrText.sans(
                  size: 12,
                  color: SpeakrColors.ink2,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _PresetTile(
              label: 'Off — use file modification time',
              selected: _selected == null,
              onTap: () => setState(() => _selected = null),
            ),
            for (final p in kDateTimePresets)
              _PresetTile(
                label: p.label,
                selected: _selected == p.id,
                onTap: () => setState(() => _selected = p.id),
              ),
            _PresetTile(
              label: 'Custom regex…',
              selected: _selected == kCustomPresetId,
              onTap: () => setState(() => _selected = kCustomPresetId),
            ),
            if (_selected == kCustomPresetId) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CustomField(label: 'Regex', controller: _regex),
                    const SizedBox(height: 10),
                    _CustomField(
                      label: 'Capture group (1-based)',
                      controller: _group,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    _CustomField(
                      label: 'DateFormat pattern',
                      controller: _format,
                      hint: 'yyyy-MM-dd HH-mm-ss',
                    ),
                    if (_customError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _customError!,
                        style: SpeakrText.sans(
                          size: 12,
                          color: SpeakrColors.danger,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  FilledButton(onPressed: _save, child: const Text('Save')),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _PresetTile extends StatelessWidget {
  const _PresetTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: SpeakrColors.line)),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? SpeakrColors.ink : SpeakrColors.line,
                  width: selected ? 6 : 1,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: SpeakrText.sans(size: 14))),
          ],
        ),
      ),
    );
  }
}

class _CustomField extends StatelessWidget {
  const _CustomField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.hint,
  });
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: SpeakrText.sans(size: 12, color: SpeakrColors.muted),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: SpeakrText.mono(size: 13, color: SpeakrColors.ink),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

// ── Tag sheet ─────────────────────────────────────────────────────────────────

class _TagLabel {
  static String of(WidgetRef ref, int? tagId) {
    if (tagId == null) return 'None';
    final tagsAsync = ref.read(tagsProvider);
    final tags = tagsAsync.value;
    if (tags == null) return 'Tag #$tagId';
    for (final t in tags) {
      if (t.id == tagId) return t.name;
    }
    return 'Tag #$tagId';
  }
}

class _TagSheet extends ConsumerWidget {
  const _TagSheet({required this.configId, required this.currentId});
  final String configId;
  final int? currentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagsProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text('Default tag', style: SpeakrText.serif(size: 22)),
          ),
          const SizedBox(height: 12),
          tagsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(color: SpeakrColors.ink),
              ),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Could not load tags: $e',
                style: SpeakrText.sans(size: 13),
              ),
            ),
            data: (tags) => Column(
              children: [
                _TagOption(
                  label: 'None',
                  selected: currentId == null,
                  onTap: () async {
                    await ref
                        .read(folderConfigsControllerProvider)
                        .setTagId(configId, null);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                for (final t in tags)
                  _TagOption(
                    label: t.name,
                    color: parseHexColor(t.color),
                    selected: currentId == t.id,
                    onTap: () async {
                      await ref
                          .read(folderConfigsControllerProvider)
                          .setTagId(configId, t.id);
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TagOption extends StatelessWidget {
  const _TagOption({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: SpeakrColors.line)),
        ),
        child: Row(
          children: [
            if (color != null) ...[
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(label, style: SpeakrText.sans(size: 14))),
            if (selected)
              const Icon(Icons.check, size: 18, color: SpeakrColors.ink),
          ],
        ),
      ),
    );
  }
}
