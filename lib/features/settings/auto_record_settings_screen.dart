import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/models.dart';
import '../../services/auto_record/auto_record_providers.dart';
import '../../services/auto_record/auto_record_settings.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/mono_eyebrow.dart';
import '../../widgets/settings_row.dart';
import '../../widgets/speakr_icons.dart';
import '../library/library_controller.dart';

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

class _AllowlistGroup extends ConsumerWidget {
  const _AllowlistGroup({required this.settings, required this.controller});
  final AutoRecordSettings settings;
  final AutoRecordSettingsController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsGroup(
      label: 'Allowlist',
      children: [
        if (settings.allowlist.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
            child: Text(
              'No apps yet. Add one below — type an exe basename, or '
              'pick from apps recently seen using your mic.',
              style: SpeakrText.sans(size: 12, color: SpeakrColors.muted),
            ),
          )
        else
          for (final entry in settings.allowlist)
            _AllowlistRow(
              entry: entry,
              defaults: settings,
              onTap: () => _openPerAppSheet(context, entry),
              onRemove: () => controller.removeFromAllowlist(entry),
            ),
      ],
    );
  }

  void _openPerAppSheet(BuildContext context, AllowlistEntry entry) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: SpeakrColors.bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (_) => _PerAppConfigSheet(entryKey: entry.key, entryKind: entry.kind),
    );
  }
}

/// One row in the allowlist list. Shows the app name and a one-line
/// summary of resolved speakers + tags (per-app override or "default").
/// Tapping the row body opens the per-app config sheet; the × button
/// removes the entry.
class _AllowlistRow extends ConsumerWidget {
  const _AllowlistRow({
    required this.entry,
    required this.defaults,
    required this.onTap,
    required this.onRemove,
  });
  final AllowlistEntry entry;
  final AutoRecordSettings defaults;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagsProvider);
    final knownTags = tagsAsync.value ?? const <Tag>[];
    final resolvedSpeakers = entry.speakers ?? defaults.defaultSpeakers;
    final speakersIsDefault = entry.speakers == null;
    final resolvedTagIds =
        entry.tagIds.isNotEmpty ? entry.tagIds : defaults.defaultTagIds;
    final tagsIsDefault = entry.tagIds.isEmpty;
    final summary = _summarize(
      resolvedSpeakers: resolvedSpeakers,
      speakersIsDefault: speakersIsDefault,
      resolvedTagIds: resolvedTagIds,
      tagsIsDefault: tagsIsDefault,
      knownTags: knownTags,
    );
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 16, 12),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: SpeakrColors.line)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.displayName,
                    style:
                        SpeakrText.sans(size: 14, color: SpeakrColors.ink),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    summary,
                    style: SpeakrText.mono(
                        size: 11,
                        color: SpeakrColors.muted,
                        letterSpacing: 0),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 18, color: SpeakrColors.muted),
            const SizedBox(width: 4),
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(3),
              child: Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                child: Text(
                  '×',
                  style: SpeakrText.serif(
                      size: 16, color: SpeakrColors.muted, height: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _summarize({
    required int resolvedSpeakers,
    required bool speakersIsDefault,
    required List<int> resolvedTagIds,
    required bool tagsIsDefault,
    required List<Tag> knownTags,
  }) {
    final speakersLabel = speakersIsDefault
        ? '$resolvedSpeakers speakers (default)'
        : '$resolvedSpeakers speakers';
    if (resolvedTagIds.isEmpty) {
      return speakersLabel;
    }
    final names = [
      for (final id in resolvedTagIds) _tagNameForId(id, knownTags),
    ];
    final tagsLabel = tagsIsDefault
        ? '${names.join(', ')} (default)'
        : names.join(', ');
    return '$speakersLabel · $tagsLabel';
  }
}

String _tagNameForId(int id, List<Tag> known) {
  for (final t in known) {
    if (t.id == id) return t.name;
  }
  return 'Tag #$id';
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
    final recent = settings.recentlySeen
        .where((r) => !_isInAllowlist(r.toAllowlistEntry()))
        .toList()
      ..sort((a, b) => b.lastSeenMs.compareTo(a.lastSeenMs));
    return SettingsGroup(
      label: 'Add app',
      children: [
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

class _BehaviorGroup extends ConsumerWidget {
  const _BehaviorGroup({required this.settings, required this.controller});
  final AutoRecordSettings settings;
  final AutoRecordSettingsController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagsProvider);
    final knownTags = tagsAsync.value ?? const <Tag>[];
    final defaultTagsLabel = settings.defaultTagIds.isEmpty
        ? 'None'
        : settings.defaultTagIds
            .map((id) => _tagNameForId(id, knownTags))
            .join(', ');
    return SettingsGroup(
      label: 'Behavior',
      children: [
        SettingsRow(
          label: 'Stop-prompt silence threshold',
          trailing: _IntStepper(
            value: settings.silenceSeconds,
            suffix: 's',
            step: 5,
            min: 5,
            max: 120,
            onChanged: controller.setSilenceSeconds,
          ),
        ),
        SettingsRow(
          label: 'Discard recordings shorter than',
          trailing: _IntStepper(
            value: settings.minKeepSeconds,
            suffix: 's',
            step: 5,
            min: 0,
            max: 120,
            onChanged: controller.setMinKeepSeconds,
          ),
        ),
        SettingsRow(
          label: 'Default speakers',
          subtitle: 'Used when an app has no per-app override.',
          trailing: _IntStepper(
            value: settings.defaultSpeakers,
            step: 1,
            min: 1,
            max: 12,
            onChanged: controller.setDefaultSpeakers,
          ),
        ),
        SettingsRow(
          label: 'Default tags',
          value: defaultTagsLabel,
          subtitle: 'Used when an app has no per-app override.',
          onTap: () {
            showModalBottomSheet<void>(
              context: context,
              backgroundColor: SpeakrColors.bg,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
              builder: (_) => _GlobalTagSheet(
                selectedIds: settings.defaultTagIds,
                onChanged: controller.setDefaultTagIds,
              ),
            );
          },
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
    this.suffix = '',
  });
  final int value;
  final int step;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final String suffix;

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
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            suffix.isEmpty ? '$value' : '$value$suffix',
            textAlign: TextAlign.center,
            style: SpeakrText.serif(size: 16),
          ),
        ),
        const SizedBox(width: 8),
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

// ── Per-app config sheet ──────────────────────────────────────────────────────

/// Modal sheet that lets the user override speakers + tags for one
/// allowlist entry. Watches [autoRecordSettingsProvider] so external
/// changes (e.g. removal from another path) and writes both reflect.
class _PerAppConfigSheet extends ConsumerWidget {
  const _PerAppConfigSheet({required this.entryKey, required this.entryKind});
  final String entryKey;
  final AllowlistKind entryKind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(autoRecordSettingsProvider);
    final controller = ref.read(autoRecordSettingsControllerProvider);
    return SafeArea(
      top: false,
      child: settingsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator(color: SpeakrColors.ink)),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Text('Could not load settings: $e',
              style: SpeakrText.sans(size: 13)),
        ),
        data: (s) {
          final entry = _findEntry(s.allowlist);
          if (entry == null) {
            // The entry was removed from elsewhere; nothing to configure.
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Text(
                'This app is no longer in the allowlist.',
                style: SpeakrText.sans(size: 13),
              ),
            );
          }
          return _PerAppConfigSheetBody(
            entry: entry,
            defaultSpeakers: s.defaultSpeakers,
            defaultTagIds: s.defaultTagIds,
            controller: controller,
          );
        },
      ),
    );
  }

  AllowlistEntry? _findEntry(List<AllowlistEntry> allowlist) {
    final probe =
        AllowlistEntry(key: entryKey, displayName: entryKey, kind: entryKind);
    for (final e in allowlist) {
      if (e == probe) return e;
    }
    return null;
  }
}

class _PerAppConfigSheetBody extends ConsumerWidget {
  const _PerAppConfigSheetBody({
    required this.entry,
    required this.defaultSpeakers,
    required this.defaultTagIds,
    required this.controller,
  });
  final AllowlistEntry entry;
  final int defaultSpeakers;
  final List<int> defaultTagIds;
  final AutoRecordSettingsController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagsProvider);
    final speakersIsDefault = entry.speakers == null;
    final tagsIsDefault = entry.tagIds.isEmpty;
    final resolvedSpeakers = entry.speakers ?? defaultSpeakers;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(entry.displayName,
                style: SpeakrText.serif(size: 22)),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'These overrides apply when ${entry.displayName} triggers '
              'an auto-recording.',
              style: SpeakrText.sans(
                  size: 12, color: SpeakrColors.muted, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          // ── Speakers ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 6),
            child: MonoEyebrow('Speakers', size: 9),
          ),
          _SheetRow(
            label: 'Use default ($defaultSpeakers)',
            selected: speakersIsDefault,
            onTap: () => controller.setEntryOverrides(
              entry,
              clearSpeakers: true,
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: SpeakrColors.line)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    speakersIsDefault ? 'Set custom' : 'Custom',
                    style: SpeakrText.sans(size: 14, color: SpeakrColors.ink),
                  ),
                ),
                _IntStepper(
                  value: resolvedSpeakers,
                  step: 1,
                  min: 1,
                  max: 12,
                  onChanged: (v) => controller.setEntryOverrides(
                    entry,
                    speakers: v,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // ── Tags ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 6),
            child: MonoEyebrow('Tags', size: 9),
          ),
          _SheetRow(
            label: defaultTagIds.isEmpty
                ? 'Use default (none)'
                : 'Use default '
                    '(${defaultTagIds.map((id) => _tagNameForId(id, tagsAsync.value ?? const [])).join(', ')})',
            selected: tagsIsDefault,
            onTap: () => controller.setEntryOverrides(
              entry,
              tagIds: const [],
            ),
          ),
          tagsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(color: SpeakrColors.ink),
              ),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: Text('Could not load tags: $e',
                  style: SpeakrText.sans(size: 13)),
            ),
            data: (tags) => Column(
              children: [
                for (final t in tags)
                  _SheetRow(
                    label: t.name,
                    color: parseHexColor(t.color),
                    selected: !tagsIsDefault && entry.tagIds.contains(t.id),
                    onTap: () {
                      // Toggle: build the next list, never empty when
                      // toggled-on (avoid revert-to-default surprise).
                      final current =
                          tagsIsDefault ? <int>[] : List<int>.from(entry.tagIds);
                      if (current.contains(t.id)) {
                        current.remove(t.id);
                      } else {
                        current.add(t.id);
                      }
                      controller.setEntryOverrides(entry, tagIds: current);
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

// ── Global default tags sheet ─────────────────────────────────────────────────

/// Multi-select picker for [AutoRecordSettings.defaultTagIds]. Used as
/// the fallback when an allowlist entry has no per-app tag override.
class _GlobalTagSheet extends ConsumerWidget {
  const _GlobalTagSheet({
    required this.selectedIds,
    required this.onChanged,
  });
  final List<int> selectedIds;
  final Future<void> Function(List<int>) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagsProvider);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child:
                  Text('Default tags', style: SpeakrText.serif(size: 22)),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Attached to auto-recordings when the triggering app has '
                'no per-app tag override.',
                style: SpeakrText.sans(
                    size: 12, color: SpeakrColors.muted, height: 1.4),
              ),
            ),
            const SizedBox(height: 12),
            _SheetRow(
              label: 'None',
              selected: selectedIds.isEmpty,
              onTap: () => onChanged(const []),
            ),
            tagsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child:
                      CircularProgressIndicator(color: SpeakrColors.ink),
                ),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                child: Text('Could not load tags: $e',
                    style: SpeakrText.sans(size: 13)),
              ),
              data: (tags) => Column(
                children: [
                  for (final t in tags)
                    _SheetRow(
                      label: t.name,
                      color: parseHexColor(t.color),
                      selected: selectedIds.contains(t.id),
                      onTap: () {
                        final next = List<int>.from(selectedIds);
                        if (next.contains(t.id)) {
                          next.remove(t.id);
                        } else {
                          next.add(t.id);
                        }
                        onChanged(next);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Selectable row inside a sheet — bordered top, optional color dot,
/// check on the right when selected.
class _SheetRow extends StatelessWidget {
  const _SheetRow({
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
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(label, style: SpeakrText.sans(size: 14)),
            ),
            if (selected)
              const Icon(Icons.check, size: 18, color: SpeakrColors.ink),
          ],
        ),
      ),
    );
  }
}
