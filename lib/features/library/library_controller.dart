import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../api/models.dart';
import '../../api/providers.dart';
import '../auto_upload/auto_upload_controller.dart';

class LibraryFilter {
  const LibraryFilter({this.statusKey = 'all', this.tagId, this.query});
  final String statusKey; // all | pending | processing | completed | failed | highlighted
  final int? tagId;
  final String? query;

  LibraryFilter copyWith({
    String? statusKey,
    int? Function()? tagId,
    String? Function()? query,
  }) =>
      LibraryFilter(
        statusKey: statusKey ?? this.statusKey,
        tagId: tagId == null ? this.tagId : tagId(),
        query: query == null ? this.query : query(),
      );
}

class LibraryFilterNotifier extends StateNotifier<LibraryFilter> {
  LibraryFilterNotifier() : super(const LibraryFilter());

  void setStatus(String key) => state = state.copyWith(statusKey: key);
  void setTag(int? id) => state = state.copyWith(tagId: () => id);
  void setQuery(String? q) {
    final v = (q == null || q.isEmpty) ? null : q;
    state = state.copyWith(query: () => v);
  }
}

final libraryFilterProvider =
    StateNotifierProvider<LibraryFilterNotifier, LibraryFilter>(
  (_) => LibraryFilterNotifier(),
);

final libraryRecordingsProvider =
    FutureProvider.autoDispose<RecordingPage>((ref) async {
  final api = ref.watch(speakrApiProvider);
  final f = ref.watch(libraryFilterProvider);
  final statusParam = (f.statusKey == 'all' || f.statusKey == 'highlighted')
      ? null
      : f.statusKey;
  final page = await api.listRecordings(
    page: 1,
    perPage: 50,
    status: statusParam,
    tagId: f.tagId,
    query: f.query,
  );
  if (f.statusKey == 'highlighted') {
    return RecordingPage(
      recordings: page.recordings.where((r) => r.isHighlighted).toList(),
      page: page.page,
      perPage: page.perPage,
      total: page.recordings.where((r) => r.isHighlighted).length,
      totalPages: 1,
    );
  }
  return page;
});

final tagsProvider = FutureProvider<List<Tag>>((ref) async {
  return ref.watch(speakrApiProvider).listTags();
});

/// One item in the merged Library list — either a server-side recording
/// or a local file in the watched auto-upload folder that hasn't been
/// uploaded yet.
sealed class LibraryItem {
  const LibraryItem();
  DateTime get when;
}

class RemoteLibraryItem extends LibraryItem {
  const RemoteLibraryItem(this.recording);
  final Recording recording;
  @override
  DateTime get when =>
      recording.meetingDate ?? recording.createdAt ?? DateTime.now();
}

class PendingLibraryItem extends LibraryItem {
  const PendingLibraryItem(this.pending);
  final PendingFile pending;
  @override
  DateTime get when => pending.dateTime;
}

/// The merged list shown on the Library screen. Pending local files take
/// precedence over their (eventual) remote counterparts and bubble to the
/// top of their respective day group.
final libraryItemsProvider =
    FutureProvider.autoDispose<List<LibraryItem>>((ref) async {
  final remote = await ref.watch(libraryRecordingsProvider.future);
  final pending = await ref.watch(pendingFilesProvider.future);
  final out = <LibraryItem>[
    ...pending.map((p) => PendingLibraryItem(p)),
    ...remote.recordings.map((r) => RemoteLibraryItem(r)),
  ];
  out.sort((a, b) => b.when.compareTo(a.when));
  return out;
});
