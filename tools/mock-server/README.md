# Speakr mock server

A small, dependency-free `dart:io` HTTP server that impersonates enough of the
Speakr REST API for the Flutter client to run end-to-end against **entirely
invented data**.

It exists for three jobs:

1. Capturing Play Store screenshots without putting real recordings into a
   public listing.
2. Acting as the **demo endpoint for the Play reviewer** (Play Console →
   App content → *App access*), which otherwise cannot get past the connection
   screen.

It is **not** part of the Flutter app build: it imports nothing from `lib/`,
adds no package dependencies, and is never referenced by app source.

---

## Run it

```bash
# from the repo root
dart run tools/mock-server/bin/speakr_mock_server.dart            # port 8420
dart run tools/mock-server/bin/speakr_mock_server.dart --port 9000
dart run tools/mock-server/bin/speakr_mock_server.dart --host 127.0.0.1
```

Defaults: `--host 0.0.0.0`, `--port 8420`. Binding to `0.0.0.0` is what lets a
phone, an emulator, or a Play reviewer reach it; use `--host 127.0.0.1` to keep
it local.

State is in memory only. Restart to reset every edit, tag and upload.

## Connect the app to it

In the Onboarding screen (step 3):

| Field | Value |
| --- | --- |
| **Server URL** | see the table below |
| **API Token** | `speakr-demo-token` |

| Where the app runs | Server URL |
| --- | --- |
| Android emulator | `http://10.0.2.2:8420` — the emulator reaches the host machine at **10.0.2.2**, never `localhost` |
| Windows desktop / same machine | `http://localhost:8420` |
| Physical phone on the same LAN | `http://<host-lan-ip>:8420` |
| Play reviewer (hosted) | `https://<your-public-host>` |

The app sends plain HTTP here; the manifest already sets
`usesCleartextTraffic="true"`, so no extra configuration is needed.

### The token

The canonical demo token is:

```
speakr-demo-token
```

**Any non-empty** `X-API-Token` or `Authorization: Bearer <…>` is accepted — the
mock does not validate the value, it only checks that one is present, so the
onboarding screen's 401 path still behaves realistically when the token field is
left blank. Hand reviewers the canonical token above so the listing, the
screenshots and the review notes all agree.

## Hosting it for a reviewer

Nothing about the server is throwaway: it is a single process with no state on
disk and no dependencies beyond the Dart SDK.

```bash
dart compile exe tools/mock-server/bin/speakr_mock_server.dart \
  -o speakr-mock-server
./speakr-mock-server --port 8420
```

Put it behind a TLS-terminating reverse proxy (Caddy, nginx, Cloudflare Tunnel)
and give the reviewer the `https://` URL plus the demo token.

---

## What it serves

Six seeded recordings, deliberately fictional, covering every status the
`StatusBadge` renders:

| id | Title | Status |
| --- | --- | --- |
| 101 | Weekly product standup | `COMPLETED` |
| 102 | Customer interview — Northwind Cartography | `COMPLETED` |
| 103 | Monthly 1:1 — engineering | `SUMMARIZING` |
| 104 | Conference talk — Designing for quiet | `PROCESSING` |
| 105 | Voice memo — parking garage idea | `PENDING` |
| 106 | Workshop walkthrough (partial) | `FAILED` |

The two `COMPLETED` rows and the `SUMMARIZING` row carry multi-speaker
transcripts with timestamps; the `COMPLETED` rows also carry Markdown summaries
(headings, a table, lists) so the Summary tab renders something worth a
screenshot.

Also seeded: 5 tags, 2 folders, 4 named speakers with suggestion scores.

### Endpoints

Derived from `lib/api/speakr_api.dart` and `openapi/speakr-openapi.json` — not
guessed. The client reaches the same server through three base paths, all of
which the router accepts:

- `/api/v1/…` — the default
- `/api/…` — `extra: {'useRootApi': true}` (recording detail, `/config`)
- `/…` — `extra: {'noApiPrefix': true}` (`/speakers/suggestions/{id}`)

| Method | Path | Notes |
| --- | --- | --- |
| `GET` | `/stats?scope=user` | Also the onboarding reachability probe |
| `GET` | `/config` | Root-API. Transcription models + connector capability flags |
| `GET` | `/recordings` | `page`, `per_page`, `status`, `sort_by`, `sort_order`, `tag_id`, `folder_id`, `q` |
| `GET` | `/recordings/{id}` | Rich detail, wrapped in `{"recording": {…}}` |
| `PATCH` | `/recordings/{id}` | Title / notes / summary / highlight / inbox / folder |
| `DELETE` | `/recordings/{id}` | |
| `GET` | `/recordings/{id}/status` | |
| `GET` | `/recordings/{id}/audio` | See "Audio" below |
| `POST` | `/recordings/{id}/chat` | Canned, clearly-labelled reply |
| `GET`/`PUT` | `/recordings/{id}/summary`, `/notes` | |
| `GET` | `/recordings/{id}/transcript` | |
| `POST` | `/recordings/{id}/transcribe`, `/summarize` | Flips status to `PROCESSING` / `SUMMARIZING` |
| `GET` | `/recordings/{id}/speakers` | `{speakers: […], suggestions: {…}}` |
| `PUT` | `/recordings/{id}/speakers/assign` | Rewrites the labels in the stored segments |
| `POST` | `/recordings/{id}/tags` · `DELETE` `/recordings/{id}/tags/{tag_id}` | |
| `GET` | `/recordings/{id}/events` | Always empty — no screen consumes it yet |
| `POST` | `/recordings/upload` | Multipart body is **drained, not parsed**; returns a new `PENDING` row sized by the byte count |
| `GET`/`POST` | `/tags` | `POST` returns `{"tag": {…}}` |
| `GET` | `/folders` | Not in the OpenAPI spec, but the client calls it |
| `GET` | `/speakers` | |
| `GET` | `/speakers/suggestions/{recording_id}` | Bare host path, no `/api` prefix |
| `PUT` | `/settings/auto-summarization` | |

Anything unrouted returns a clean `404` with `{"error": "…"}`.

### Response-shape fidelity

Two real-server quirks are reproduced on purpose, because the client depends on
both (see AGENTS.md pitfalls 4 and the `_parseFlexibleDate` note in
`lib/api/models.dart`):

- **Envelope wrapping.** `GET`/`PATCH` on a single recording return
  `{"recording": {…}}`; `POST /tags` returns `{"tag": {…}}`; the list endpoint
  returns the array unwrapped. `SpeakrApi._unwrap` tolerates both — this makes
  sure that code path is actually exercised.
- **Two date encodings.** The v1 list endpoint emits ISO-8601
  (`2026-09-21T09:02:00`); the unofficial detail endpoint emits the
  babel-formatted `Sep 21, 2026, 9:02:00 AM` — with a **U+202F narrow no-break
  space** before AM/PM, exactly as the real server does.

Transcripts are returned the way the real detail endpoint returns them: the
`transcription` field is a **JSON-encoded string** of
`{speaker, sentence, start_time, end_time}` objects, not a JSON array.

### Audio

`GET /recordings/{id}/audio` serves a generated, **valid** 16-bit mono PCM WAV
(`audio/wav`) — a quiet alternating two-note tone whose length matches the
recording's `audio_duration`, capped at 30 s. It is synthesised at request time,
so no binary blob is committed to the repo, and ExoPlayer / `just_audio` play it
without complaint, which is what makes the detail screen's player render a real
duration and scrubber.

It is deliberately **not** a hand-built m4a: a truncated or malformed m4a would
make the player error out, which is worse for a screenshot than an honest WAV.
Recordings with no audio (the `FAILED` row) return a clean `404`.

## Smoke test

```bash
T='X-API-Token: speakr-demo-token'
curl -s -H "$T" localhost:8420/api/v1/stats
curl -s -H "$T" 'localhost:8420/api/v1/recordings?page=1&per_page=25'
curl -s -H "$T" localhost:8420/api/recordings/101
curl -s -H "$T" localhost:8420/api/config
curl -s -H "$T" localhost:8420/speakers/suggestions/101
curl -s -o /dev/null -w '%{http_code} %{content_type} %{size_download}\n' \
  -H "$T" localhost:8420/api/v1/recordings/101/audio
curl -s -o /dev/null -w '%{http_code}\n' localhost:8420/api/v1/stats   # 401
```
