import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/auto_record/auto_record_providers.dart';
import '../../services/auto_record/auto_record_settings.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/mono_eyebrow.dart';
import '../../widgets/settings_row.dart';
import '../../widgets/speakr_icons.dart';
import '../../widgets/tag_chip.dart';

class AutoRecordSettingsScreen extends ConsumerStatefulWidget {
  const AutoRecordSettingsScreen({super.key});

  @override
  ConsumerState<AutoRecordSettingsScreen> createState() =>
      _AutoRecordSettingsScreenState();
}

class _AutoRecordSettingsScreenState
    extends ConsumerState<AutoRecordSettingsScreen> {
  final _customCtrl = TextEditingController();

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(autoRecordSettingsProvider);
    final micUsersAsync = ref.watch(micUsersProvider);
    final controller = ref.read(autoRecordSettingsControllerProvider);

    return Scaffold(
      backgroundColor: SpeakrColors.bg,
      body: SafeArea(
        child: settingsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: SpeakrColors.ink),
          ),
          error: (e, _) => Center(child: Text('Could not load settings: $e')),
          data: (s) {
            final activeMicUsers =
                micUsersAsync.value?.where((u) => u.isInUse).toList() ??
                    const [];
            return ListView(
              padding: const EdgeInsets.only(bottom: 32),
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
                        child: MonoEyebrow('Auto-record', size: 10),
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
                        'Auto-record on mic activity',
                        style: SpeakrText.serif(size: 28, height: 1.1),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'When an allowlisted app starts using your '
                        'microphone, Speakr automatically begins '
                        'recording. Recording continues until the app '
                        'releases the mic and audio has been quiet for '
                        '${s.silenceSeconds} seconds — then Speakr asks '
                        'whether to stop.',
                        style: SpeakrText.sans(
                          size: 13,
                          color: SpeakrColors.ink2,
                          height: 1.45,
                        ),
                      ),
                      if (!Platform.isWindows) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Windows only. This screen is read-only on '
                          'other platforms.',
                          style: SpeakrText.sans(
                            size: 12,
                            color: SpeakrColors.danger,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SettingsGroup(
                  label: 'Master',
                  children: [
                    SettingsRow(
                      label: 'Enable auto-record',
                      toggleValue: s.enabled,
                      onToggle: Platform.isWindows
                          ? (v) => controller.setEnabled(v)
                          : null,
                    ),
                  ],
                ),
                _AllowlistGroup(
                  settings: s,
                  controller: controller,
                ),
                _SuggestionsGroup(
                  settings: s,
                  controller: controller,
                  customCtrl: _customCtrl,
                ),
                _BehaviorGroup(settings: s, controller: controller),
                _StatusGroup(activeUsers: activeMicUsers),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AllowlistGroup extends StatelessWidget {
  const _AllowlistGroup({required this.settings, required this.controller});
  final AutoRecordSettings settings;
  final AutoRecordSettingsController controller;

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      label: 'Allowlist',
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
          child: settings.allowlist.isEmpty
              ? Text(
                  'No apps yet. Add one from Suggestions below.',
                  style: SpeakrText.sans(
                      size: 12, color: SpeakrColors.muted),
                )
              : Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final entry in settings.allowlist)
                      CustomColorTagChip(
                        label: entry.displayName,
                        color: SpeakrColors.ink,
                        filled: true,
                        onTap: () => controller.removeFromAllowlist(entry),
                        trailing: Text(
                          '×',
                          style: SpeakrText.serif(
                            size: 11,
                            color: SpeakrColors.bg.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _SuggestionsGroup extends StatelessWidget {
  const _SuggestionsGroup({
    required this.settings,
    required this.controller,
    required this.customCtrl,
  });
  final AutoRecordSettings settings;
  final AutoRecordSettingsController controller;
  final TextEditingController customCtrl;

  bool _isInAllowlist(AllowlistEntry entry) =>
      settings.allowlist.contains(entry);

  @override
  Widget build(BuildContext context) {
    final presets =
        kPresetMeetingApps.where((e) => !_isInAllowlist(e)).toList();
    final recent = settings.recentlySeen
        .where((r) => !_isInAllowlist(r.toAllowlistEntry()))
        .toList()
      ..sort((a, b) => b.lastSeenMs.compareTo(a.lastSeenMs));
    return SettingsGroup(
      label: 'Suggestions',
      children: [
        if (presets.isNotEmpty)
          _SuggestionRow(
            title: 'Common meeting apps',
            children: [
              for (final e in presets)
                _AddChip(
                  label: e.displayName,
                  onTap: () => controller.addToAllowlist(e),
                ),
            ],
          ),
        if (recent.isNotEmpty)
          _SuggestionRow(
            title: 'Recently seen using your mic',
            children: [
              for (final r in recent.take(12))
                _AddChip(
                  label: r.displayName,
                  onTap: () =>
                      controller.addToAllowlist(r.toAllowlistEntry()),
                ),
            ],
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: customCtrl,
                  style: SpeakrText.sans(size: 13),
                  decoration: const InputDecoration(
                    hintText: 'Custom app — exe basename, e.g. Mumble.exe',
                    isDense: true,
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: SpeakrColors.line),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: SpeakrColors.line),
                    ),
                  ),
                  onSubmitted: (v) => _addCustom(v, controller),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _addCustom(customCtrl.text, controller),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: SpeakrColors.line),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const MonoEyebrow('Add', size: 9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addCustom(String raw, AutoRecordSettingsController c) {
    final v = raw.trim();
    if (v.isEmpty) return;
    c.addToAllowlist(AllowlistEntry(
      key: v,
      displayName: v,
      kind: AllowlistKind.exeBasename,
    ));
    customCtrl.clear();
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonoEyebrow(title, size: 9),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: children),
        ],
      ),
    );
  }
}

class _AddChip extends StatelessWidget {
  const _AddChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: SpeakrColors.line),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('+ ',
                style: SpeakrText.mono(
                    size: 11, color: SpeakrColors.muted, letterSpacing: 0)),
            Text(
              label,
              style: SpeakrText.sans(size: 12, color: SpeakrColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}

class _BehaviorGroup extends StatelessWidget {
  const _BehaviorGroup({required this.settings, required this.controller});
  final AutoRecordSettings settings;
  final AutoRecordSettingsController controller;

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      label: 'Behavior',
      children: [
        SettingsRow(
          label: 'Stop-prompt silence threshold',
          value: '${settings.silenceSeconds}s',
          trailing: _IntStepper(
            value: settings.silenceSeconds,
            step: 5,
            min: 5,
            max: 120,
            onChanged: controller.setSilenceSeconds,
          ),
        ),
        SettingsRow(
          label: 'Discard recordings shorter than',
          value: '${settings.minKeepSeconds}s',
          trailing: _IntStepper(
            value: settings.minKeepSeconds,
            step: 5,
            min: 0,
            max: 120,
            onChanged: controller.setMinKeepSeconds,
          ),
        ),
        SettingsRow(
          label: 'Default speakers',
          value: '${settings.defaultSpeakers}',
          trailing: _IntStepper(
            value: settings.defaultSpeakers,
            step: 1,
            min: 1,
            max: 12,
            onChanged: controller.setDefaultSpeakers,
          ),
        ),
      ],
    );
  }
}

class _IntStepper extends StatelessWidget {
  const _IntStepper({
    required this.value,
    required this.step,
    required this.min,
    required this.max,
    required this.onChanged,
  });
  final int value;
  final int step;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap:
              value > min ? () => onChanged((value - step).clamp(min, max)) : null,
          child: Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: SpeakrColors.line),
              shape: BoxShape.circle,
            ),
            child: Text('−', style: SpeakrText.serif(size: 14, height: 1)),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap:
              value < max ? () => onChanged((value + step).clamp(min, max)) : null,
          child: Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: SpeakrColors.line),
              shape: BoxShape.circle,
            ),
            child: Text('+', style: SpeakrText.serif(size: 14, height: 1)),
          ),
        ),
      ],
    );
  }
}

class _StatusGroup extends StatelessWidget {
  const _StatusGroup({required this.activeUsers});
  final List activeUsers; // List<MicUser>; relaxed type to avoid extra import

  @override
  Widget build(BuildContext context) {
    final summary = activeUsers.isEmpty
        ? 'No apps currently using the mic.'
        : activeUsers.map((u) => u.displayName).join(', ');
    return SettingsGroup(
      label: 'Status',
      children: [
        SettingsRow(
          label: 'Currently using mic',
          value: summary,
        ),
      ],
    );
  }
}
