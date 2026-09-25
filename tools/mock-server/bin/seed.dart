// Seed data + in-memory store for the Speakr mock server.
//
// Everything here is invented. No real people, companies, or meetings.
// Response shapes mirror lib/api/models.dart and openapi/speakr-openapi.json,
// including the `{recording: {...}}` / `{tag: {...}}` wrapping that
// SpeakrApi._unwrap tolerates, and the two different date encodings the real
// server uses (ISO-8601 on the v1 list, babel-formatted on the detail
// endpoint, complete with the U+202F narrow no-break space before AM/PM).

import 'dart:convert';

/// Documented demo token. Any non-empty token is accepted; this is the one the
/// README and the Play Console "App access" form hand out.
const demoToken = 'speakr-demo-token';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _iso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}T'
    '${d.hour.toString().padLeft(2, '0')}:'
    '${d.minute.toString().padLeft(2, '0')}:'
    '${d.second.toString().padLeft(2, '0')}';

/// "Sep 21, 2026, 9:02:00 AM" — note the U+202F before AM/PM, exactly as the
/// real (babel-backed) detail endpoint emits it.
String _babel(DateTime d) {
  final h24 = d.hour;
  final h = h24 % 12 == 0 ? 12 : h24 % 12;
  final ampm = h24 < 12 ? 'AM' : 'PM';
  return '${_months[d.month - 1]} ${d.day}, ${d.year}, '
      '$h:${d.minute.toString().padLeft(2, '0')}:'
      '${d.second.toString().padLeft(2, '0')} $ampm';
}

class Rec {
  Rec({
    required this.id,
    required this.title,
    required this.meetingDate,
    required this.createdAt,
    required this.status,
    this.participants,
    this.fileSize = 0,
    this.audioDuration = 0,
    this.isHighlighted = false,
    this.isInbox = false,
    this.summary,
    this.notes,
    this.segments = const [],
    List<int>? tagIds,
    this.folderId,
    this.errorMessage,
    this.queuePosition,
    this.statusMessage,
    this.originalFilename,
    this.language = 'en',
    this.transcriptionModel = 'whisper-large-v3',
    this.minSpeakers,
    this.maxSpeakers,
  }) : tagIds = tagIds ?? <int>[];

  final int id;
  String title;
  final DateTime meetingDate;
  final DateTime createdAt;
  String status;
  String? participants;
  int fileSize;
  double audioDuration;
  bool isHighlighted;
  bool isInbox;
  String? summary;
  String? notes;
  List<Map<String, Object?>> segments;
  final List<int> tagIds;
  int? folderId;
  String? errorMessage;
  int? queuePosition;
  String? statusMessage;
  String? originalFilename;
  String? language;
  String? transcriptionModel;
  int? minSpeakers;
  int? maxSpeakers;

  bool get audioAvailable => status != 'FAILED' && fileSize > 0;
  bool get hasTranscription => segments.isNotEmpty;
  bool get hasSummary => (summary ?? '').isNotEmpty;

  List<Map<String, Object?>> tagObjects(Store store) => tagIds
      .map(store.tagById)
      .whereType<Map<String, Object?>>()
      .toList(growable: false);

  /// Shape returned by GET /api/v1/recordings (the list endpoint).
  Map<String, Object?> toListJson(Store store) => {
        'id': id,
        'title': title,
        'meeting_date': _iso(meetingDate),
        'created_at': _iso(createdAt),
        'participants': participants,
        'file_size': fileSize,
        'is_highlighted': isHighlighted,
        'is_inbox': isInbox,
        'status': status,
        'tags': tagObjects(store),
        'folder_id': folderId,
        'folder': store.folderStub(folderId),
        'audio_available': audioAvailable,
        'error_message': errorMessage,
        'has_summary': hasSummary,
        'has_transcription': hasTranscription,
        'original_filename': originalFilename,
        'audio_duration': audioDuration,
      };

  /// Shape returned by GET /api/recordings/{id} (the richer, unofficial
  /// detail endpoint the client prefers). Dates use the babel format.
  Map<String, Object?> toDetailJson(Store store) => {
        'id': id,
        'title': title,
        'meeting_date': _babel(meetingDate),
        'created_at': _babel(createdAt),
        'participants': participants,
        'file_size': fileSize,
        'is_highlighted': isHighlighted,
        'is_inbox': isInbox,
        'status': status,
        'tags': tagObjects(store),
        'folder_id': folderId,
        'audio_available': audioAvailable,
        'error_message': errorMessage,
        'has_summary': hasSummary,
        'has_transcription': hasTranscription,
        'original_filename': originalFilename,
        'summary': summary,
        'notes': notes,
        // The real endpoint serialises the segment list as a JSON string.
        'transcription': segments.isEmpty ? null : jsonEncode(segments),
        'audio_duration': audioDuration,
        'transcription_model': transcriptionModel,
        'language': language,
        'min_speakers': minSpeakers,
        'max_speakers': maxSpeakers,
        'hotwords': null,
        'initial_prompt': null,
      };

  void applyPatch(Map<String, dynamic> patch) {
    if (patch.containsKey('title')) title = '${patch['title']}';
    if (patch.containsKey('participants')) {
      participants = patch['participants']?.toString();
    }
    if (patch.containsKey('notes')) notes = patch['notes']?.toString();
    if (patch.containsKey('summary')) summary = patch['summary']?.toString();
    if (patch.containsKey('is_highlighted')) {
      isHighlighted = patch['is_highlighted'] == true;
    }
    if (patch.containsKey('is_inbox')) isInbox = patch['is_inbox'] == true;
    if (patch.containsKey('folder_id')) {
      folderId = int.tryParse('${patch['folder_id']}');
    }
  }

  /// GET /recordings/{id}/speakers — derived from the transcript segments.
  List<Map<String, Object?>> speakerRoster() {
    final counts = <String, int>{};
    for (final s in segments) {
      final label = '${s['speaker'] ?? 'SPEAKER_00'}';
      counts[label] = (counts[label] ?? 0) + 1;
    }
    return counts.entries
        .map((e) => <String, Object?>{
              'label': e.key,
              'identified_name': e.key.startsWith('SPEAKER_') ? null : e.key,
              'segment_count': e.value,
              'speaker_id': null,
            })
        .toList(growable: false);
  }

  void assignSpeakers(Map<String, Object?> speakerMap) {
    for (final seg in segments) {
      final current = '${seg['speaker']}';
      final replacement = speakerMap[current];
      if (replacement == null) continue;
      seg['speaker'] = replacement is Map
          ? '${replacement['name'] ?? current}'
          : '$replacement';
    }
  }
}

class Store {
  bool autoSummarization = true;

  final List<Map<String, Object?>> tags = [
    {'id': 1, 'name': 'standup', 'color': '#3DDC97', 'custom_prompt': null},
    {'id': 2, 'name': 'research', 'color': '#7C6CF0', 'custom_prompt': null},
    {'id': 3, 'name': 'one-on-one', 'color': '#E8A33D', 'custom_prompt': null},
    {'id': 4, 'name': 'talks', 'color': '#4A9BE8', 'custom_prompt': null},
    {'id': 5, 'name': 'memo', 'color': '#B4B4AE', 'custom_prompt': null},
  ];

  final List<Map<String, Object?>> folders = [
    {'id': 1, 'name': 'Team', 'color': '#3DDC97', 'recording_count': 3},
    {'id': 2, 'name': 'Discovery', 'color': '#7C6CF0', 'recording_count': 2},
  ];

  final List<Map<String, Object?>> speakers = [
    {
      'id': 1,
      'name': 'Nadia Okonkwo',
      'has_voice_profile': true,
      'use_count': 41,
      'last_used': '2026-09-21T09:02:00',
    },
    {
      'id': 2,
      'name': 'Tomas Fielding',
      'has_voice_profile': true,
      'use_count': 33,
      'last_used': '2026-09-19T14:10:00',
    },
    {
      'id': 3,
      'name': 'Priya Ramanathan',
      'has_voice_profile': false,
      'use_count': 18,
      'last_used': '2026-09-18T11:00:00',
    },
    {
      'id': 4,
      'name': 'Dev Halloran',
      'has_voice_profile': true,
      'use_count': 12,
      'last_used': '2026-09-15T16:40:00',
    },
  ];

  late final List<Rec> recordings = _seed();

  int _nextRecordingId = 200;
  int _nextTagId = 100;

  Rec? byId(int id) {
    for (final r in recordings) {
      if (r.id == id) return r;
    }
    return null;
  }

  Map<String, Object?>? tagById(int id) {
    for (final t in tags) {
      if (t['id'] == id) return t;
    }
    return null;
  }

  /// `/recordings` payloads embed a denormalized `{id, name}` folder stub.
  Map<String, Object?>? folderStub(int? id) {
    if (id == null) return null;
    for (final f in folders) {
      if (f['id'] == id) return {'id': f['id'], 'name': f['name']};
    }
    return null;
  }

  Map<String, Object?> createTag(Map<String, dynamic> body) {
    final tag = <String, Object?>{
      'id': _nextTagId++,
      'name': '${body['name'] ?? 'untitled'}',
      'color': body['color']?.toString() ?? '#B4B4AE',
      'custom_prompt': body['custom_prompt']?.toString(),
    };
    tags.add(tag);
    return tag;
  }

  Rec acceptUpload(int bytes) {
    final now = DateTime.now();
    final rec = Rec(
      id: _nextRecordingId++,
      title: 'Uploaded recording',
      meetingDate: now,
      createdAt: now,
      status: 'PENDING',
      fileSize: bytes,
      queuePosition: 1,
      statusMessage: 'Queued for transcription.',
      originalFilename: 'upload-${now.millisecondsSinceEpoch}.m4a',
    );
    recordings.insert(0, rec);
    return rec;
  }

  Map<String, Object?> listRecordings(Map<String, String> q) {
    var rows = [...recordings];
    final status = q['status'];
    if (status != null && status.isNotEmpty) {
      rows = rows.where((r) => r.status == status).toList();
    }
    final tagId = int.tryParse(q['tag_id'] ?? '');
    if (tagId != null) {
      rows = rows.where((r) => r.tagIds.contains(tagId)).toList();
    }
    final folderId = int.tryParse(q['folder_id'] ?? '');
    if (folderId != null) {
      rows = rows.where((r) => r.folderId == folderId).toList();
    }
    final query = (q['q'] ?? '').trim().toLowerCase();
    if (query.isNotEmpty) {
      rows = rows
          .where((r) =>
              r.title.toLowerCase().contains(query) ||
              (r.summary ?? '').toLowerCase().contains(query))
          .toList();
    }
    final desc = (q['sort_order'] ?? 'desc') != 'asc';
    rows.sort((a, b) => desc
        ? b.meetingDate.compareTo(a.meetingDate)
        : a.meetingDate.compareTo(b.meetingDate));

    final page = int.tryParse(q['page'] ?? '') ?? 1;
    final perPage = int.tryParse(q['per_page'] ?? '') ?? 25;
    final start = (page - 1) * perPage;
    final slice = start >= rows.length
        ? const <Rec>[]
        : rows.sublist(start, (start + perPage).clamp(0, rows.length));

    return {
      'recordings': slice.map((r) => r.toListJson(this)).toList(growable: false),
      'page': page,
      'per_page': perPage,
      'total': rows.length,
      'total_pages': rows.isEmpty ? 1 : (rows.length + perPage - 1) ~/ perPage,
    };
  }

  Map<String, Object?> suggestionsFor(int recordingId) {
    final rec = byId(recordingId);
    if (rec == null || rec.segments.isEmpty) return const {};
    final labels = rec
        .speakerRoster()
        .map((s) => '${s['label']}')
        .where((l) => l.startsWith('SPEAKER_'))
        .toList();
    final out = <String, Object?>{};
    for (var i = 0; i < labels.length && i < speakers.length; i++) {
      final s = speakers[i];
      out[labels[i]] = [
        {
          'speaker_id': s['id'],
          'name': s['name'],
          'confidence': 0.91 - i * 0.07,
          'similarity': 0.88 - i * 0.05,
          'embedding_count': 6 - i,
        },
      ];
    }
    return out;
  }

  String chatReply(Rec rec, String message) {
    final head = rec.hasTranscription
        ? 'Looking at "${rec.title}"'
        : 'There is no transcript for "${rec.title}" yet';
    return '$head — this is the Speakr mock server, so the answer is canned.\n\n'
        'You asked: "$message"\n\n'
        'On a real server this is where the model\'s grounded answer would '
        'appear, citing the transcript segments it drew from.';
  }

  Map<String, Object?> config() => {
        'transcription_model_options': [
          {'label': 'Whisper large-v3', 'value': 'whisper-large-v3'},
          {'label': 'Whisper medium', 'value': 'whisper-medium'},
          {'label': 'Distil large-v3', 'value': 'distil-large-v3'},
        ],
        'connector_supports_diarization': true,
        'connector_supports_speaker_count': true,
        'connector_supports_hotwords': true,
        'connector_supports_initial_prompt': true,
      };

  Map<String, Object?> stats() {
    final completed = recordings.where((r) => r.status == 'COMPLETED').length;
    final failed = recordings.where((r) => r.status == 'FAILED').length;
    final pending = recordings.where((r) => r.status == 'PENDING').length;
    final processing = recordings
        .where((r) => r.status == 'PROCESSING' || r.status == 'SUMMARIZING')
        .length;
    final bytes = recordings.fold<int>(0, (a, r) => a + r.fileSize);
    return {
      'activity': {
        'last_transcription': '2026-09-21T09:41:00',
        'recordings_today': 2,
      },
      'queue': {'jobs_processing': processing, 'jobs_queued': pending},
      'recordings': {
        'completed': completed,
        'failed': failed,
        'pending': pending,
        'processing': processing,
        'total': recordings.length,
      },
      'storage': {
        'used_bytes': bytes,
        'used_human': '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB',
      },
      'tokens': {'budget': 2000000, 'percentage': 21.4, 'used_this_month': 428000},
      'transcription': {
        'budget_minutes': 1200,
        'budget_seconds': 72000,
        'estimated_cost': 3.18,
        'percentage': 14.9,
        'used_this_month_minutes': 179,
        'used_this_month_seconds': 10740,
      },
    };
  }
}

// ── Seeds ───────────────────────────────────────────────────────────────────

List<Map<String, Object?>> _segments(List<List<Object>> rows) {
  final out = <Map<String, Object?>>[];
  for (final r in rows) {
    out.add({
      'speaker': r[0],
      'start_time': r[1],
      'end_time': r[2],
      'sentence': r[3],
    });
  }
  return out;
}

List<Rec> _seed() {
  DateTime at(int day, int hour, int minute) =>
      DateTime(2026, 9, day, hour, minute);

  return [
    // 1 — COMPLETED, the richest row; the detail screenshot uses this one.
    Rec(
      id: 101,
      title: 'Weekly product standup',
      meetingDate: at(21, 9, 2),
      createdAt: at(21, 9, 2),
      status: 'COMPLETED',
      participants: 'Nadia Okonkwo, Tomas Fielding, Priya Ramanathan',
      fileSize: 18_442_112,
      audioDuration: 1187.4,
      tagIds: [1],
      folderId: 1,
      originalFilename: 'standup-2026-09-21.m4a',
      minSpeakers: 2,
      maxSpeakers: 4,
      notes: 'Priya to circulate the import spec before Thursday.',
      summary: '''
## Weekly product standup

**Date:** 21 September 2026 · **Duration:** 19 min · **Speakers:** 3

### Decisions

- Ship the bulk-import screen behind a flag for the next release; the flag
  comes off once the migration guide is written.
- Hold the redesigned filter bar until after the import work lands, to avoid
  two large changes in the same release.

### Action items

| Owner | Item | Due |
| --- | --- | --- |
| Priya | Circulate the import spec | Thursday |
| Tomas | Add retry telemetry to the upload worker | End of week |
| Nadia | Draft the migration guide | Next standup |

### Notes

The team agreed the import screen is close enough to demo internally. The one
open question is what happens to partially-imported batches when the network
drops mid-upload — Tomas is adding telemetry first so the decision is made on
data rather than guesswork.
''',
      segments: _segments([
        ['SPEAKER_00', 0.0, 6.4, 'Morning, everyone. Short one today — three items, then we are done.'],
        ['SPEAKER_00', 6.8, 14.2, 'First up, the bulk import screen. Priya, where did that land?'],
        ['SPEAKER_02', 14.6, 27.1, 'It is functional. You can point it at a folder, it queues everything, and the progress list updates as jobs finish.'],
        ['SPEAKER_02', 27.4, 38.9, 'What I have not solved is what happens when the network drops halfway through a batch. Right now the partial batch just sits there.'],
        ['SPEAKER_01', 39.5, 51.0, 'That is the same failure mode we had with the upload worker last quarter. I would rather add retry telemetry before we design the fix.'],
        ['SPEAKER_01', 51.3, 60.8, 'Give me until the end of the week and we will actually know how often it happens.'],
        ['SPEAKER_00', 61.2, 72.6, 'Agreed. Ship it behind a flag, we demo it internally, and the flag comes off once the migration guide exists.'],
        ['SPEAKER_00', 73.0, 80.4, 'Second item — the filter bar redesign. I want to hold it.'],
        ['SPEAKER_02', 80.9, 91.3, 'No objection. Two big changes in one release is how we ended up doing that emergency patch in June.'],
        ['SPEAKER_01', 91.8, 99.2, 'Fine by me. It is mostly CSS at this point anyway, it will keep.'],
        ['SPEAKER_00', 99.6, 110.5, 'Last thing: I will draft the migration guide before next standup. Anything else? No? Good, see you Thursday.'],
      ]),
    ),

    // 2 — COMPLETED, a second full row so the library shows two green states.
    Rec(
      id: 102,
      title: 'Customer interview — Northwind Cartography',
      meetingDate: at(19, 14, 10),
      createdAt: at(19, 14, 10),
      status: 'COMPLETED',
      participants: 'Nadia Okonkwo, Dev Halloran',
      fileSize: 31_207_936,
      audioDuration: 2043.8,
      tagIds: [2],
      folderId: 2,
      isHighlighted: true,
      originalFilename: 'interview-northwind.m4a',
      minSpeakers: 2,
      maxSpeakers: 2,
      summary: '''
## Customer interview — Northwind Cartography

**Segment:** small survey firm, 11 staff · **Duration:** 34 min

### What they do today

Field surveyors dictate notes into a phone recorder and type them up in the
evening. Roughly 40 minutes of transcription per surveyor per day, done badly
and late.

### Pain points, in their words

1. *"The notes are useless a week later because nobody writes down who said
   what."* — speaker attribution matters more than raw accuracy.
2. Site names and equipment codes are mangled by every generic transcriber
   they have tried.
3. They will not put site recordings on someone else's cloud; the client
   contracts forbid it.

### Fit

Strong. Self-hosting is a requirement rather than a preference for them, and
the custom-vocabulary hooks address the mangled-terminology complaint. The gap
is offline capture — they are frequently out of signal on site.
''',
      segments: _segments([
        ['SPEAKER_00', 0.0, 9.8, 'Thanks for making the time. I want to understand how the notes actually get written today, before we talk about tools at all.'],
        ['SPEAKER_01', 10.3, 24.7, 'Honestly? Badly. The surveyors talk into their phones on site and then type it all up in the evening, usually after dinner, usually annoyed.'],
        ['SPEAKER_01', 25.1, 36.9, 'Call it forty minutes a day each. And the quality drops the later it gets, which is exactly when the important detail goes missing.'],
        ['SPEAKER_00', 37.4, 44.0, 'When you go back to those notes a week later, what is missing?'],
        ['SPEAKER_01', 44.5, 58.2, 'Who said what. That is the big one. The notes are useless a week later because nobody writes down who said what.'],
        ['SPEAKER_01', 58.6, 71.4, 'Second thing is the vocabulary. Site names, equipment codes — every transcriber we have tried turns them into nonsense.'],
        ['SPEAKER_00', 71.9, 79.3, 'Have you looked at any of the hosted transcription services for this?'],
        ['SPEAKER_01', 79.8, 93.5, 'We looked. We cannot use them. Our client contracts say site recordings do not leave our infrastructure, full stop.'],
        ['SPEAKER_01', 93.9, 104.2, 'So anything we adopt has to run on a box we own. That rules out most of the market immediately.'],
        ['SPEAKER_00', 104.7, 113.1, 'That is useful. One more — how much of the day are you actually in signal?'],
        ['SPEAKER_01', 113.6, 126.0, 'Less than you would think. Half the sites are dead zones. Anything that needs a live connection to record is a non-starter.'],
      ]),
    ),

    // 3 — SUMMARIZING: transcript is in, summary still being generated.
    Rec(
      id: 103,
      title: 'Monthly 1:1 — engineering',
      meetingDate: at(22, 11, 0),
      createdAt: at(22, 11, 0),
      status: 'SUMMARIZING',
      participants: 'Nadia Okonkwo, Tomas Fielding',
      fileSize: 12_988_416,
      audioDuration: 842.1,
      tagIds: [3],
      folderId: 1,
      statusMessage: 'Generating summary…',
      originalFilename: 'one-on-one-sep.m4a',
      segments: _segments([
        ['SPEAKER_00', 0.0, 8.2, 'Usual format — what is going well, what is in your way, and anything you want from me.'],
        ['SPEAKER_01', 8.7, 21.4, 'Going well: the upload worker is finally boring. I have not been paged about it in six weeks, which is the highest praise I can give it.'],
        ['SPEAKER_01', 21.9, 34.6, 'In my way: I am the only person who understands the retry logic. If I am out, nobody can touch it safely.'],
        ['SPEAKER_00', 35.0, 43.8, 'That is a fair thing to raise. Would a walkthrough with Priya fix it, or does it need documentation?'],
        ['SPEAKER_01', 44.2, 56.9, 'Both, probably. A walkthrough gets someone else oriented, but the state machine genuinely needs a diagram.'],
      ]),
    ),

    // 4 — PROCESSING: transcription in flight, nothing to show yet.
    Rec(
      id: 104,
      title: 'Conference talk — Designing for quiet',
      meetingDate: at(22, 10, 30),
      createdAt: at(22, 10, 30),
      status: 'PROCESSING',
      participants: 'Priya Ramanathan',
      fileSize: 47_316_992,
      audioDuration: 2712.0,
      tagIds: [4],
      statusMessage: 'Transcribing — 41% complete.',
      originalFilename: 'talk-designing-for-quiet.m4a',
    ),

    // 5 — PENDING: queued, waiting for a worker.
    Rec(
      id: 105,
      title: 'Voice memo — parking garage idea',
      meetingDate: at(22, 8, 15),
      createdAt: at(22, 8, 15),
      status: 'PENDING',
      fileSize: 1_204_224,
      audioDuration: 74.6,
      tagIds: [5],
      isInbox: true,
      queuePosition: 2,
      statusMessage: 'Queued — 2 jobs ahead.',
      originalFilename: 'memo-0815.m4a',
    ),

    // 6 — FAILED: renders the error state and the retry affordance.
    Rec(
      id: 106,
      title: 'Workshop walkthrough (partial)',
      meetingDate: at(18, 16, 45),
      createdAt: at(18, 16, 45),
      status: 'FAILED',
      fileSize: 0,
      audioDuration: 0,
      tagIds: [5],
      errorMessage: 'Upload truncated — the source file ended mid-frame.',
      statusMessage: 'Upload truncated — the source file ended mid-frame.',
      originalFilename: 'workshop-walkthrough.m4a',
    ),
  ];
}
