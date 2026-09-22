// Speakr mock server — dev-only.
//
// A standalone dart:io HTTP server that speaks enough of the Speakr REST API
// for the Flutter client to run against fully-invented data. Used to capture
// Play Store screenshots without exposing a real Speakr instance, and intended
// to double as the Play reviewer demo endpoint.
//
// Not part of the Flutter app build: it imports nothing from `lib/` and no
// package dependencies. Run it with plain `dart run`:
//
//   dart run tools/mock-server/bin/speakr_mock_server.dart --port 8420
//
// See README.md next to this file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'seed.dart';

const defaultPort = 8420;

Future<void> main(List<String> args) async {
  var port = defaultPort;
  var host = '0.0.0.0';
  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--port':
      case '-p':
        port = int.parse(args[++i]);
      case '--host':
        host = args[++i];
      case '--help':
      case '-h':
        stdout.writeln(
          'Usage: dart run speakr_mock_server.dart '
          '[--port $defaultPort] [--host 0.0.0.0]',
        );
        return;
    }
  }

  final store = Store();
  final server = await HttpServer.bind(host, port);
  stdout
    ..writeln('Speakr mock server listening on http://$host:$port')
    ..writeln('  demo token      : $demoToken')
    ..writeln('  android emulator: http://10.0.2.2:$port')
    ..writeln('  seeded          : ${store.recordings.length} recordings');

  await for (final req in server) {
    try {
      await _handle(req, store);
    } catch (e, st) {
      stderr.writeln('! ${req.method} ${req.uri}: $e');
      stderr.writeln(st);
    }
  }
}

// ── Routing ─────────────────────────────────────────────────────────────────

Future<void> _handle(HttpRequest req, Store store) async {
  final method = req.method;
  final rawPath = req.uri.path;
  stdout.writeln('$method $rawPath');

  if (method == 'OPTIONS') {
    _cors(req.response);
    req.response.statusCode = 204;
    await req.response.close();
    return;
  }

  // The client reaches the same server through three base URLs:
  //   <base>/api/v1  (default), <base>/api (useRootApi), <base> (noApiPrefix).
  var path = rawPath;
  if (path.startsWith('/api/v1')) {
    path = path.substring('/api/v1'.length);
  } else if (path.startsWith('/api')) {
    path = path.substring('/api'.length);
  }
  final seg = path.split('/').where((s) => s.isNotEmpty).toList();

  if (seg.isEmpty) {
    _json(req, {
      'service': 'speakr-mock-server',
      'recordings': store.recordings.length,
    });
    return;
  }

  if (!_authorized(req)) {
    _json(req, {'error': 'Missing or empty API token.'}, status: 401);
    return;
  }

  // GET /speakers/suggestions/{recording_id} — bare host, no /api prefix.
  if (method == 'GET' &&
      seg.length == 3 &&
      seg[0] == 'speakers' &&
      seg[1] == 'suggestions') {
    _json(req, {
      'success': true,
      'suggestions': store.suggestionsFor(int.tryParse(seg[2]) ?? -1),
    });
    return;
  }

  switch (seg[0]) {
    case 'stats':
      if (method == 'GET') {
        _json(req, store.stats());
        return;
      }
    case 'config':
      if (method == 'GET') {
        _json(req, store.config());
        return;
      }
    case 'tags':
      if (seg.length == 1 && method == 'GET') {
        _json(req, {'tags': store.tags});
        return;
      }
      if (seg.length == 1 && method == 'POST') {
        _json(req, {'tag': store.createTag(await _body(req))}, status: 201);
        return;
      }
    case 'folders':
      if (seg.length == 1 && method == 'GET') {
        _json(req, {'folders': store.folders});
        return;
      }
    case 'speakers':
      if (seg.length == 1 && method == 'GET') {
        _json(req, {'speakers': store.speakers});
        return;
      }
    case 'settings':
      if (seg.length == 2 && seg[1] == 'auto-summarization' && method == 'PUT') {
        final body = await _body(req);
        store.autoSummarization = body['enabled'] == true;
        _json(req, {'success': true, 'enabled': store.autoSummarization});
        return;
      }
    case 'recordings':
      await _recordings(req, store, method, seg);
      return;
  }

  _json(req, {'error': 'No mock route for $method $rawPath'}, status: 404);
}

Future<void> _recordings(
  HttpRequest req,
  Store store,
  String method,
  List<String> seg,
) async {
  // GET /recordings
  if (seg.length == 1 && method == 'GET') {
    _json(req, store.listRecordings(req.uri.queryParameters));
    return;
  }

  // POST /recordings/upload — the multipart body is drained, not parsed; the
  // mock only needs the byte count to make the new row look plausible.
  if (seg.length == 2 && seg[1] == 'upload' && method == 'POST') {
    var bytes = 0;
    await for (final chunk in req) {
      bytes += chunk.length;
    }
    _json(req, {'recording': store.acceptUpload(bytes).toDetailJson(store)},
        status: 201);
    return;
  }

  final id = seg.length >= 2 ? int.tryParse(seg[1]) : null;
  final rec = id == null ? null : store.byId(id);
  if (rec == null) {
    _json(req, {'error': 'Recording not found.'}, status: 404);
    return;
  }

  // /recordings/{id}
  if (seg.length == 2) {
    switch (method) {
      case 'GET':
        _json(req, {'recording': rec.toDetailJson(store)});
        return;
      case 'PATCH':
        rec.applyPatch(await _body(req));
        _json(req, {'recording': rec.toDetailJson(store)});
        return;
      case 'DELETE':
        store.recordings.remove(rec);
        _json(req, {'success': true});
        return;
    }
  }

  if (seg.length >= 3) {
    switch (seg[2]) {
      case 'audio':
        if (method == 'GET') {
          _audio(req, rec);
          return;
        }
      case 'status':
        if (method == 'GET') {
          _json(req, {
            'status': rec.status,
            'queue_position': rec.queuePosition,
            'message': rec.statusMessage,
          });
          return;
        }
      case 'chat':
        if (method == 'POST') {
          final body = await _body(req);
          _json(req, {'response': store.chatReply(rec, '${body['message']}')});
          return;
        }
      case 'transcript':
        if (method == 'GET') {
          _json(req, {'transcription': rec.segments});
          return;
        }
      case 'summary':
        if (method == 'GET') {
          _json(req, {'summary': rec.summary});
          return;
        }
        if (method == 'PUT') {
          rec.summary = '${(await _body(req))['summary'] ?? rec.summary}';
          _json(req, {'success': true, 'summary': rec.summary});
          return;
        }
      case 'notes':
        if (method == 'GET') {
          _json(req, {'notes': rec.notes});
          return;
        }
        if (method == 'PUT') {
          rec.notes = '${(await _body(req))['notes'] ?? ''}';
          _json(req, {'success': true, 'notes': rec.notes});
          return;
        }
      case 'transcribe':
        if (method == 'POST') {
          await _body(req);
          rec.status = 'PROCESSING';
          rec.statusMessage = 'Re-transcribing (mock).';
          _json(req, {'success': true, 'status': rec.status});
          return;
        }
      case 'summarize':
        if (method == 'POST') {
          await _body(req);
          rec.status = 'SUMMARIZING';
          rec.statusMessage = 'Re-summarizing (mock).';
          _json(req, {'success': true, 'status': rec.status});
          return;
        }
      case 'speakers':
        if (seg.length == 3 && method == 'GET') {
          _json(req, {
            'speakers': rec.speakerRoster(),
            'suggestions': store.suggestionsFor(rec.id),
          });
          return;
        }
        if (seg.length == 4 && seg[3] == 'assign' && method == 'PUT') {
          final body = await _body(req);
          rec.assignSpeakers(
            (body['speaker_map'] as Map?)?.cast<String, Object?>() ?? const {},
          );
          _json(req, {'success': true, 'recording': rec.toDetailJson(store)});
          return;
        }
      case 'tags':
        if (seg.length == 3 && method == 'POST') {
          final body = await _body(req);
          final ids = (body['tag_ids'] as List? ?? const [])
              .map((e) => int.tryParse('$e'))
              .whereType<int>();
          for (final tid in ids) {
            if (store.tagById(tid) != null && !rec.tagIds.contains(tid)) {
              rec.tagIds.add(tid);
            }
          }
          _json(req, {'success': true, 'tags': rec.tagObjects(store)});
          return;
        }
        if (seg.length == 4 && method == 'DELETE') {
          rec.tagIds.remove(int.tryParse(seg[3]));
          _json(req, {'success': true});
          return;
        }
      case 'events':
        if (method == 'GET') {
          _json(req, {'events': const <Object>[]});
          return;
        }
    }
  }

  _json(req, {'error': 'No mock route for $method ${req.uri.path}'},
      status: 404);
}

// ── Plumbing ────────────────────────────────────────────────────────────────

bool _authorized(HttpRequest req) {
  final token = req.headers.value('X-API-Token');
  if (token != null && token.trim().isNotEmpty) return true;
  final auth = req.headers.value('Authorization') ?? '';
  return auth.toLowerCase().startsWith('bearer ') && auth.trim().length > 7;
}

void _cors(HttpResponse res) {
  res.headers
    ..set('Access-Control-Allow-Origin', '*')
    ..set('Access-Control-Allow-Headers',
        'Authorization, X-API-Token, Content-Type, Accept')
    ..set('Access-Control-Allow-Methods',
        'GET, POST, PUT, PATCH, DELETE, OPTIONS');
}

void _json(HttpRequest req, Object? body, {int status = 200}) {
  final res = req.response;
  _cors(res);
  res
    ..statusCode = status
    ..headers.contentType = ContentType('application', 'json', charset: 'utf-8')
    ..write(jsonEncode(body));
  unawaited(res.close());
}

Future<Map<String, dynamic>> _body(HttpRequest req) async {
  final raw = await utf8.decoder.bind(req).join();
  if (raw.trim().isEmpty) return <String, dynamic>{};
  final decoded = jsonDecode(raw);
  return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
}

void _audio(HttpRequest req, Rec rec) {
  if (!rec.audioAvailable) {
    _json(req, {'error': 'No audio for this recording.'}, status: 404);
    return;
  }
  final wav = _toneWav(seconds: rec.audioDuration.round().clamp(1, 30));
  final res = req.response;
  _cors(res);
  res
    ..statusCode = 200
    ..headers.contentType = ContentType('audio', 'wav')
    ..headers.set('Accept-Ranges', 'none')
    ..headers.contentLength = wav.length
    ..add(wav);
  unawaited(res.close());
}

/// A real, valid 16-bit mono PCM WAV: a quiet alternating two-note tone.
/// Generated rather than committed so no binary blob lives in the repo, and
/// valid rather than a truncated m4a so the detail player renders a real
/// duration and scrubber instead of erroring.
Uint8List _toneWav({int seconds = 12, int sampleRate = 22050}) {
  final frames = seconds * sampleRate;
  final pcm = Uint8List(frames * 2);
  for (var i = 0; i < frames; i++) {
    final t = i / sampleRate;
    final freq = (t.floor() % 2 == 0) ? 220.0 : 277.2;
    // Fade each second in and out so it reads as a cadence, not a drone.
    final env = math.sin(math.pi * (t - t.floorToDouble()));
    final v = (math.sin(2 * math.pi * freq * t) * env * 6000).round();
    pcm[i * 2] = v & 0xFF;
    pcm[i * 2 + 1] = (v >> 8) & 0xFF;
  }
  final out = BytesBuilder();
  final header = ByteData(44);
  void ascii(int off, String s) {
    for (var i = 0; i < s.length; i++) {
      header.setUint8(off + i, s.codeUnitAt(i));
    }
  }

  ascii(0, 'RIFF');
  header.setUint32(4, 36 + pcm.length, Endian.little);
  ascii(8, 'WAVE');
  ascii(12, 'fmt ');
  header.setUint32(16, 16, Endian.little); // PCM chunk size
  header.setUint16(20, 1, Endian.little); // format = PCM
  header.setUint16(22, 1, Endian.little); // channels
  header.setUint32(24, sampleRate, Endian.little);
  header.setUint32(28, sampleRate * 2, Endian.little); // byte rate
  header.setUint16(32, 2, Endian.little); // block align
  header.setUint16(34, 16, Endian.little); // bits per sample
  ascii(36, 'data');
  header.setUint32(40, pcm.length, Endian.little);
  out
    ..add(header.buffer.asUint8List())
    ..add(pcm);
  return out.takeBytes();
}
