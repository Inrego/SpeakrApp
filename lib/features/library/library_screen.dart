import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/models.dart';
import '../../services/preferences/time_format_preference.dart';
import '../../services/preferences/time_format_providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../utils/formatters.dart';
import '../../widgets/folder_chip.dart';
import '../../widgets/mono_eyebrow.dart';
import '../../widgets/speakr_icons.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/tag_chip.dart';
import '../auto_upload/auto_upload_controller.dart';
import '../auto_upload/auto_upload_settings_store.dart';
import '../auto_upload/auto_upload_worker.dart';
import '../live/live_controller.dart';
import 'library_controller.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  bool _searching = false;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncItems = ref.watch(libraryItemsProvider);
    final filter = ref.watch(libraryFilterProvider);
    final totalCount = asyncItems.value?.length ?? 0;
    final recording = ref.watch(recordingControllerProvider);
    final isRecording = recording.started || recording.uploading;
    return Scaffold(
      backgroundColor: SpeakrColors.bg,
      floatingActionButton: isRecording
          ? null
          : _RecordFab(onTap: () => context.push('/live')),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              searching: _searching,
              searchCtrl: _searchCtrl,
              onToggleSearch: () => setState(() {
                _searching = !_searching;
                if (!_searching) {
                  _searchCtrl.clear();
                  ref.read(libraryFilterProvider.notifier).setQuery(null);
                }
              }),
              onSubmitSearch: (v) {
                ref.read(libraryFilterProvider.notifier).setQuery(v.trim());
              },
              onSettings: () => context.push('/settings'),
            ),
            _Title(total: totalCount),
            _FilterChips(filter: filter),
            _FolderFilterRow(filter: filter),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                color: SpeakrColors.ink,
                onRefresh: () async {
                  ref.invalidate(pendingFilesProvider);
                  ref.invalidate(pendingFileErrorsProvider);
                  ref.invalidate(libraryRecordingsProvider);
                  await ref.read(libraryItemsProvider.future);
                },
                child: asyncItems.when(
                  loading: () => const _Loading(),
                  error: (e, _) => _ErrorView(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(libraryRecordingsProvider),
                  ),
                  data: (items) =>
                      items.isEmpty ? const _Empty() : _ItemsList(items: items),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.searching,
    required this.searchCtrl,
    required this.onToggleSearch,
    required this.onSubmitSearch,
    required this.onSettings,
  });
  final bool searching;
  final TextEditingController searchCtrl;
  final VoidCallback onToggleSearch;
  final ValueChanged<String> onSubmitSearch;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: searching
                ? TextField(
                    controller: searchCtrl,
                    autofocus: true,
                    onSubmitted: onSubmitSearch,
                    style: SpeakrText.sans(size: 14),
                    decoration: InputDecoration(
                      hintText: 'Search recordings…',
                      isDense: true,
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintStyle: SpeakrText.sans(
                        size: 14,
                        color: SpeakrColors.muted,
                      ),
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: MonoEyebrow('Speakr'),
                  ),
          ),
          GhostIconButton(
            icon: searching ? SpeakrIcon.close : SpeakrIcon.search,
            onTap: onToggleSearch,
          ),
          GhostIconButton(icon: SpeakrIcon.settings, onTap: onSettings),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.total});
  final int total;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recordings', style: SpeakrText.serif(size: 38, height: 1.05)),
          const SizedBox(height: 6),
          Text(
            total > 0 ? '$total total' : 'No recordings yet',
            style: SpeakrText.sans(size: 13, color: SpeakrColors.muted),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends ConsumerWidget {
  const _FilterChips({required this.filter});
  final LibraryFilter filter;

  static const _chips = [
    ('all', 'All'),
    ('highlighted', 'Highlighted'),
    ('completed', 'Completed'),
    ('processing', 'Processing'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final (key, label) = _chips[i];
          final selected = filter.statusKey == key;
          return InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: () =>
                ref.read(libraryFilterProvider.notifier).setStatus(key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? SpeakrColors.ink : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
                border: selected ? null : Border.all(color: SpeakrColors.line),
              ),
              child: Center(
                child: Text(
                  label,
                  style: SpeakrText.sans(
                    size: 13,
                    color: selected ? SpeakrColors.bg : SpeakrColors.ink2,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FolderFilterRow extends ConsumerWidget {
  const _FolderFilterRow({required this.filter});
  final LibraryFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.watch(foldersProvider);
    final folders = foldersAsync.value ?? const <Folder>[];
    if (folders.isEmpty) return const SizedBox.shrink();
    final notifier = ref.read(libraryFilterProvider.notifier);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: SizedBox(
        height: 32,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: folders.length + 1,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (_, i) {
            if (i == 0) {
              return FolderFilterChip(
                label: 'All',
                color: SpeakrColors.muted,
                selected: filter.folderId == null,
                onTap: () => notifier.setFolder(null),
                showSwatch: false,
              );
            }
            final f = folders[i - 1];
            return FolderFilterChip(
              label: f.name,
              color: parseHexColor(f.color),
              selected: filter.folderId == f.id,
              onTap: () => notifier
                  .setFolder(filter.folderId == f.id ? null : f.id),
            );
          },
        ),
      ),
    );
  }
}

class _ItemsList extends StatelessWidget {
  const _ItemsList({required this.items});
  final List<LibraryItem> items;

  @override
  Widget build(BuildContext context) {
    final groups = groupBy<LibraryItem, String>(
      items,
      (i) => formatRelativeDay(i.when),
    );
    final entries = groups.entries.toList();
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 0, bottom: 120),
      itemCount: entries.length,
      itemBuilder: (_, i) {
        final entry = entries[i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 6),
              child: MonoEyebrow(entry.key, size: 10),
            ),
            for (final it in entry.value)
              switch (it) {
                RemoteLibraryItem(:final recording) => _RecordingTile(
                  recording: recording,
                ),
                PendingLibraryItem(:final pending) => _PendingTile(
                  pending: pending,
                ),
              },
          ],
        );
      },
    );
  }
}

class _PendingTile extends ConsumerStatefulWidget {
  const _PendingTile({required this.pending});
  final PendingFile pending;

  @override
  ConsumerState<_PendingTile> createState() => _PendingTileState();
}

class _PendingTileState extends ConsumerState<_PendingTile> {
  bool _uploading = false;
  String? _error;

  Future<void> _confirmAndUpload({bool forceFromError = false}) async {
    if (!forceFromError) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: SpeakrColors.bg,
          title: Text(
            'Upload this recording?',
            style: SpeakrText.serif(size: 20),
          ),
          content: Text(
            '${widget.pending.file.path.split(RegExp(r"[\\/]")).last}\n\n'
            'The file will be uploaded to your Speakr server and removed '
            'from this device.',
            style: SpeakrText.sans(size: 13, color: SpeakrColors.ink2),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Upload'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    setState(() {
      _uploading = true;
      _error = null;
    });
    try {
      await uploadOneFile(widget.pending.file, widget.pending.config);
      final store = await AutoUploadSettingsStore.open();
      final fileStillExists = await widget.pending.file.exists();
      if (!fileStillExists) {
        await store.clearFileError(widget.pending.file.path);
        await store.clearUploadedFile(widget.pending.file.path);
      }
      ref.invalidate(pendingFilesProvider);
      ref.invalidate(pendingFileErrorsProvider);
      ref.invalidate(libraryRecordingsProvider);
      if (mounted && fileStillExists) {
        setState(() {
          _uploading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _error = e.toString();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_error!)));
    }
  }

  Future<void> _showScanError(String errorMessage) async {
    final action = await showDialog<_PendingErrorAction>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: SpeakrColors.bg,
        title: Text(
          "Couldn't process recording",
          style: SpeakrText.serif(size: 20),
        ),
        content: Text(
          errorMessage,
          style: SpeakrText.sans(
            size: 13,
            color: SpeakrColors.ink2,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogCtx, _PendingErrorAction.delete),
            style: TextButton.styleFrom(foregroundColor: SpeakrColors.danger),
            child: const Text('Delete file'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogCtx, _PendingErrorAction.forceUpload),
            child: const Text('Force upload'),
          ),
        ],
      ),
    );
    if (action == null) return;
    switch (action) {
      case _PendingErrorAction.delete:
        await _deleteLocalFile();
        break;
      case _PendingErrorAction.forceUpload:
        await _confirmAndUpload(forceFromError: true);
        break;
    }
  }

  Future<void> _deleteLocalFile() async {
    final deleteError = await deleteLocalAutoUploadFile(widget.pending.file);
    if (deleteError != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete file: $deleteError')),
      );
      return;
    }
    final store = await AutoUploadSettingsStore.open();
    await store.clearFileError(widget.pending.file.path);
    await store.clearUploadedFile(widget.pending.file.path);
    if (!mounted) return;
    ref.invalidate(pendingFilesProvider);
    ref.invalidate(pendingFileErrorsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pending;
    final name = p.file.path.split(RegExp(r'[\\/]')).last;
    final errors =
        ref.watch(pendingFileErrorsProvider).asData?.value ??
        const <String, String>{};
    final scanError = errors[p.file.path];
    final hasError = scanError != null;

    void Function()? onTap;
    if (_uploading) {
      onTap = null;
    } else if (hasError) {
      onTap = () => _showScanError(scanError);
    } else {
      onTap = () => _confirmAndUpload();
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: SpeakrColors.line)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SpeakrText.serif(
                      size: 17,
                      height: 1.25,
                      color: SpeakrColors.ink2,
                      style: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Builder(builder: (context) {
                    final pref = ref.watch(timeFormatPreferenceProvider).asData?.value
                        ?? TimeFormatPreference.system;
                    final use24 = resolveUse24Hour(pref, context);
                    return Text(
                      '${formatHourMinute(p.dateTime, use24Hour: use24)} · ${formatBytes(p.size)}',
                      style: SpeakrText.sans(size: 12, color: SpeakrColors.muted),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (_uploading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: SpeakrColors.ink,
                ),
              )
            else if (hasError)
              const _ErrorBadge()
            else
              const _NotUploadedBadge(),
          ],
        ),
      ),
    );
  }
}

enum _PendingErrorAction { delete, forceUpload }

class _NotUploadedBadge extends StatelessWidget {
  const _NotUploadedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: SpeakrColors.line),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: SpeakrColors.muted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'not uploaded',
            style: SpeakrText.mono(size: 10, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}

class _ErrorBadge extends StatelessWidget {
  const _ErrorBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: SpeakrColors.danger),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: SpeakrColors.danger,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'error',
            style: SpeakrText.mono(
              size: 10,
              letterSpacing: 1,
              color: SpeakrColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordingTile extends ConsumerWidget {
  const _RecordingTile({required this.recording});
  final Recording recording;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = recording;
    final completed = r.status == RecordingStatus.completed;
    // Failed often just means summary generation failed — audio and transcript
    // are usually still viewable, so let the user open it.
    final enterable = completed || r.status == RecordingStatus.failed;
    final time = (r.meetingDate ?? r.createdAt);
    final speakers = (r.participants ?? '')
        .split(',')
        .where((s) => s.trim().isNotEmpty)
        .length;
    final pref = ref.watch(timeFormatPreferenceProvider).asData?.value
        ?? TimeFormatPreference.system;
    final use24 = resolveUse24Hour(pref, context);
    final folders = ref.watch(foldersProvider).value ?? const <Folder>[];
    final folder = r.folder;
    final folderColor = resolveFolderColor(r.folderId, folders);
    return InkWell(
      onTap: enterable ? () => context.push('/recording/${r.id}') : null,
      child: Stack(
        children: [
          if (folder != null)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 3, color: folderColor),
            ),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: SpeakrColors.line)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (folder != null) ...[
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: folderColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        folder.name.toUpperCase(),
                        style: SpeakrText.mono(
                          size: 9.5,
                          color: folderColor,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (r.isHighlighted)
                                const Padding(
                                  padding: EdgeInsets.only(right: 6),
                                  child:
                                      SpeakrIconView(SpeakrIcon.star, size: 14),
                                ),
                              Flexible(
                                child: Text(
                                  r.title?.isNotEmpty == true
                                      ? r.title!
                                      : 'Untitled recording',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      SpeakrText.serif(size: 17, height: 1.25),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _subtitle(time, speakers, use24),
                            style: SpeakrText.sans(
                              size: 12,
                              color: SpeakrColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (completed &&
                        r.audioDuration != null &&
                        r.audioDuration! > 0) ...[
                      const SizedBox(width: 10),
                      Text(
                        formatDuration(r.audioDuration!),
                        style: SpeakrText.mono(
                          size: 11,
                          color: SpeakrColors.muted,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                    if (!completed) ...[
                      const SizedBox(width: 10),
                      StatusBadge(status: r.status),
                    ],
                  ],
                ),
                if (r.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: r.tags.map((t) => TagChip(tag: t)).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _subtitle(DateTime? when, int speakers, bool use24Hour) {
    final t = when == null ? '' : formatHourMinute(when, use24Hour: use24Hour);
    if (speakers > 1) return '$t · $speakers speakers';
    return t;
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 80),
        Center(
          child: CircularProgressIndicator(
            color: SpeakrColors.ink,
            strokeWidth: 2,
          ),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      children: [
        const MonoEyebrow('Empty'),
        const SizedBox(height: 12),
        Text(
          'Nothing to show yet.',
          style: SpeakrText.serif(size: 26, height: 1.15),
        ),
        const SizedBox(height: 14),
        Text(
          'Tap the mic in the corner to make your first recording.',
          style: SpeakrText.sans(
            size: 15,
            height: 1.5,
            color: SpeakrColors.ink2,
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      children: [
        const MonoEyebrow('Couldn’t load'),
        const SizedBox(height: 8),
        Text(message, style: SpeakrText.sans(size: 14)),
        const SizedBox(height: 16),
        OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}

class _RecordFab extends StatelessWidget {
  const _RecordFab({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: FloatingActionButton(
        onPressed: onTap,
        backgroundColor: SpeakrColors.ink,
        elevation: 8,
        shape: const CircleBorder(),
        child: const SpeakrIconView(
          SpeakrIcon.mic,
          size: 26,
          color: SpeakrColors.bg,
        ),
      ),
    );
  }
}
