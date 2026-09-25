# Google Play — Store Listing Copy

This file holds the text fields for the Google Play Console "Main store listing"
page. Character limits are noted per field; the drafts below stay within them.

---

## App title (max 30 chars)

```
Speakr
```

(6 chars. Plenty of headroom — kept to the bare app name to match the launcher
label `android:label="Speakr"` and the desktop branding.)

Alternative if a longer, more descriptive title is desired (still ≤30):

```
Speakr — Transcribe Client
```

(26 chars.)

---

## Short description (max 80 chars)

```
Record & transcribe meetings on your own self-hosted Speakr server.
```

(67 chars.)

Alternatives (both ≤80):

- `Client for your self-hosted Speakr transcription server.` (56 chars)
- `Record, upload & review AI transcripts on your Speakr server.` (61 chars)

---

## Full description (max 4000 chars)

```
Speakr is a client for the self-hosted, open-source Speakr transcription and
meeting-notes server. It records, uploads, and reviews AI-transcribed
meetings — and it talks ONLY to the Speakr instance you configure.

IMPORTANT: This app is not affiliated with the Speakr server project and is not
a standalone service. You must run (or have access to) your own Speakr server
and supply an API token from the server's Account → API Tokens page. Without a
reachable Speakr server, the app cannot transcribe anything.

WHAT YOU CAN DO

• Record meetings live, with a tag picker and pause/resume. Optionally capture
  the audio other apps are playing (the other side of a call or video meeting)
  alongside your microphone — Android asks for its consent dialog each time.
• Upload existing audio files (m4a, mp3, wav, and more) with options for
  minimum/maximum speakers, language, tags, meeting date, and notes.
• Watch transcription progress with live status badges: Pending → Processing →
  Summarizing → Completed.
• Read the results: a Markdown AI summary, a speaker-attributed transcript, and
  a chat tab for asking questions about the recording — all in one detail view.
• Review and rename speakers, with autocomplete from your global speaker list
  and per-segment suggestions.

AUTOMATION

• Background auto-upload watcher (Android and Windows): pick a folder — for
  example your call recorder's output folder — and new audio files in it upload
  to your server automatically, then the local copy is deleted so your device
  does not fill up. Optionally skip and delete recordings shorter than a
  minimum you set.
• On Android you choose each folder in the system folder picker; Speakr only
  gets access to the folders you pick, never to the rest of your storage.
• On Android, the watcher can run a scan after a phone call ends, so call
  recordings are picked up without opening the app.

DESKTOP EXTRAS (WINDOWS)

• Always-on-top mini recorder that survives app switching.
• Auto-record that starts when an application you choose (e.g. your meeting
  app) begins using the microphone, and offers to stop when it goes quiet.

PRIVACY BY DESIGN

• Your audio and metadata are sent only to the server you configure. There is
  no hard-coded backend and no third-party telemetry.
• Your server URL and API token are stored in your device's OS secure storage
  (Android Keystore-backed). They are never logged.
• No analytics SDKs. No advertising. No data shared with the developer.

REQUIREMENTS

• A reachable Speakr server (REST API v1) and an API token from it.
• Microphone permission for live recording.
• For auto-upload only: access to the folders you pick, granted through your
  device's own folder picker. Speakr requests no other storage access.

Speakr is cross-platform: Android, iOS, and Windows desktop. (iOS builds are
not produced in this project's CI.)
```

(Approx. 2,810 characters — under the 4,000 limit. Trim or expand freely.)

---

## Category & tags

- **Application type:** App (not Game)
- **Category:** Productivity (primary suggestion)
  - Alternative: Business
- **Tags:** choose from Play's controlled tag list at publish time
  (e.g. "Productivity", "Tools"). No free-form tags.
- **Content rating:** expected **Everyone** (confirmed via the rating
  questionnaire — see `checklist.md`).

---

## Contact details

- **Email (required, public):** rss@khd.dk
- **Website (optional):** consider linking the GitHub repo —
  https://github.com/Inrego/SpeakrApp
- **Phone (optional):** leave blank unless you want it public.

---

## Privacy policy URL (REQUIRED)

Google Play **requires** a privacy policy URL for this app because it requests
sensitive permissions (microphone, phone state, capturing other apps' audio
through media projection) and handles user-generated content (audio). Storage
permissions are **not** among them: Android auto-upload uses a per-folder
Storage Access Framework grant, `MANAGE_EXTERNAL_STORAGE` **was removed** in #4,
and the permission audit (#7) removed `READ_MEDIA_AUDIO` and
`READ_EXTERNAL_STORAGE` as well — the app now declares **no storage permission
of any kind** (see `permissions-declaration.md` §1 and §8).

The policy exists: source of truth `privacy-policy.md`, published from
`site/privacy-policy.html` at
**https://inrego.github.io/SpeakrApp/privacy-policy.html**. Enter that URL in
**Play Console → App content → Privacy policy**.

The policy states, accurately for this app:

- The app is a client for a **user-self-hosted** Speakr server. The developer
  does not operate a backend and does not receive user data.
- Audio recordings and associated metadata (tags, notes, speaker names, meeting
  date) are transmitted **only** to the server URL the user configures.
- The server URL and API token are stored locally in the device's OS secure
  storage and are not transmitted to the developer or any third party.
- No analytics, advertising, or third-party tracking SDKs are integrated
  (verified against `pubspec.yaml` — no Firebase/Analytics/Crashlytics/ads
  dependencies present).
- The app can capture other apps' audio (Android media projection, Windows
  loopback), and auto-upload deletes files from the user-chosen folders after
  upload — on Android through the SAF grant to those folders only.
- The Windows build monitors which applications use the microphone, locally
  only, to drive auto-record.
- How users can request deletion: since the developer holds no data, deletion
  is performed on the user's own Speakr server / device.

**Action required from you: paste the URL into the Console.** Keep the listing
text above consistent with the policy whenever either changes.

---

## Notes / things to confirm

- **Title length:** "Speakr" alone is safest. If you want the descriptive
  variant, confirm it doesn't collide with another Play app named "Speakr".
- **"AI" claims:** the description says "AI summary / AI-transcribed". This is
  accurate to the server's behavior; keep it factual and avoid implying the app
  itself does on-device AI.
- **iOS line** is included for honesty; remove it from the Play listing if you
  prefer to keep the listing Android-only in tone (Play only lists the Android
  build regardless).
