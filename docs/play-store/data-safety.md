# Google Play — Data Safety Form (first draft)

This is a **draft** answer set for the Play Console **Data safety** section
(App content → Data safety). Review every answer before submitting — you are
legally responsible for its accuracy.

These answers reflect what the app's code actually does, verified against the
repository:

- No analytics, advertising, crash-reporting, or third-party tracking SDKs are
  present in `pubspec.yaml` (no Firebase / Analytics / Crashlytics / Sentry /
  ads / Facebook / Amplitude / Mixpanel / Segment, etc.).
- The app sends user data **only** to the Speakr server the user configures.
  There is no developer-operated backend.
- The server URL and API token are stored in OS secure storage
  (`flutter_secure_storage`, Android Keystore-backed).
- The app can capture **other apps' audio** (Android `MediaProjection` +
  `AudioPlaybackCaptureConfiguration`, `SpeakrAudioRecorder.kt`) and it
  **deletes source files from the user's watched folders** after upload, plus
  files shorter than a user-set minimum duration (`auto_upload_worker.dart`).
  Both are disclosed in `privacy-policy.md` (sections "Recording other apps'
  audio" and "Auto-upload, folder access, and deletion of your files") and
  the answers below reflect them.
- On Android the watched folders are reached through a **Storage Access
  Framework tree grant** per folder the user picked — not All files access.
  `MANAGE_EXTERNAL_STORAGE` is being removed (the code change is in a separate
  PR; until it merges, builds from `main` still request it). No answer in this
  form depended on All files access: the scope of what auto-upload reads and
  deletes — the user-chosen folders — is the same either way, only the
  permission mechanism narrows.

> **Revision 2026-09-22 — what changed in this draft, and why.** The policy
> was corrected to disclose system-audio capture, delete-after-upload of files
> the app did not create, and the Windows microphone-usage monitor. Google
> cross-checks this form against the hosted policy, so every row was re-read
> against both. Changes: (1) **Audio** now states the recording may contain
> other apps' audio and other call participants, and that auto-upload
> collects audio *files* produced by other apps — both are the same "Voice or
> sound recordings" / "Other audio files" types, still Collected, still not
> Shared; (2) **metadata** now lists the file name and last-modified time sent
> for auto-uploaded files; (3) **Section C** gained explicit notes that the
> Windows mic monitor's app list is local-only and outside the Android form's
> scope, and that media projection never captures screen pixels (so
> "Photos and videos" stays No); (4) the **free text** now mentions system
> audio and delete-after-upload; (5) confirm-item 4 updated to the pending
> Pages URL. No top-level Yes/No answer flipped: the app already declared
> audio as Collected; the corrections widen *what* that audio can contain,
> they do not add a data type that was previously answered No.

> **Key framing for the form:** Play asks whether YOUR app "collects or shares"
> user data. Google's definition of "collect" = transmitted off the device.
> Because audio + metadata ARE transmitted off the device (to the user's own
> server), they count as **collected** even though the developer never receives
> them. The destination being the user's own server does not exempt it from the
> form. Answer honestly that data is collected/transferred, and use the
> free-text and "processed ephemerally / user can request deletion" options to
> explain the self-hosted model.

---

## Section A — Data collection & sharing (top-level answers)

| Question | Draft answer | Rationale |
|---|---|---|
| Does your app collect or share any of the required user data types? | **Yes** | Audio + metadata are transmitted to the user's server; that counts as "collected". |
| Is all of the user data encrypted in transit? | **See note** | The app supports HTTPS, but `usesCleartextTraffic="true"` allows HTTP to self-hosted/LAN servers. **You must decide how to answer.** Safest honest answer: data is encrypted in transit **only if the user's server uses HTTPS**; the app does not force TLS. Google's checkbox is all-or-nothing — if HTTP is possible, you arguably **cannot** check "all encrypted in transit". Recommend leaving it **unchecked** and explaining in review notes, OR enforce HTTPS in a future build. **CONFIRM WITH USER.** |
| Do you provide a way for users to request that their data is deleted? | **Yes (qualified)** | The developer holds no data; deletion happens on the user's own server/device. Explain in the policy. |

---

## Section B — Data types collected

Mark each as **Collected** (transmitted off device) and **not Shared** (Google
defines "shared" as transfer to a *third party*; the user's own self-hosted
server is the user's designated destination, not a third party — but see the
caveat note at the bottom).

### Audio files / voice or sound recordings

- **Collected:** Yes
- **Shared:** No (sent only to the user's configured server)
- **Processed ephemerally:** No (the recording is uploaded and stored on the
  user's server for transcription)
- **Required or optional:** Required for the core recording/upload feature
- **Purpose:** App functionality (recording, upload, transcription)
- **User data deletion:** handled on the user's server
- **What the audio can contain (state this in the free text):**
  - the user's microphone;
  - **other apps' playback audio** captured via `MediaProjection` when the
    user turns on the system-audio source for a session — that can include
    other participants of a call or video meeting, subject to Android only
    exposing `USAGE_MEDIA` / `USAGE_GAME` / `USAGE_UNKNOWN` streams and to
    apps opting out;
  - **audio files written by other apps** (call recorders, voice recorders)
    that auto-upload picks up from user-chosen folders. Under Play's taxonomy
    these fall under Audio → "Voice or sound recordings" and/or "Other audio
    files"; tick both so the auto-upload path is covered.
- **Deletion from the device:** after a successful upload the app deletes the
  source file from the watched folder, and deletes files shorter than a
  user-set minimum duration without uploading them. This is not a form field,
  but it is in the policy, so the free text should say it too (see Section E).
  On Android the delete happens through the user's SAF folder grant; there is
  no All-files-access declaration to keep it consistent with.

### "Other" user-generated content — meeting metadata

Tags, notes, speaker names, meeting date, language/speaker-count settings.
For auto-uploaded files, also the **file name** and **last-modified time**
(sent as the meeting date).

- **Collected:** Yes
- **Shared:** No
- **Required/optional:** Optional (metadata fields are optional)
- **Purpose:** App functionality

### App activity / other — transcripts & summaries

These are produced **by the server** and displayed in the app; they are
downloaded from the user's server, not collected by the developer. If the form
asks only about data the app *sends/collects from the user*, transcripts are
server-generated content fetched back — generally **not** a "collected" type
the developer must declare. **CONFIRM** by reading Play's current definitions;
when in doubt, declare under "App info and performance → Other app data" as
user-content fetched from the user's own server.

### Credentials — API token & server URL

- **Collected by the developer/transmitted to third parties:** **No**
- These are stored **locally** in OS secure storage and sent only to the user's
  own server as an auth header. They are not transmitted to the developer or any
  third party.
- Google's Data Safety form is about data leaving the device to the developer or
  third parties; locally stored credentials that only authenticate to the user's
  own server are **not** "collected" in Play's sense. Do **not** list the token
  as collected-by-developer. (If the form's "Personal info → User IDs / other"
  prompts, note in free text that auth tokens are stored locally and encrypted.)

---

## Section C — Data NOT collected (explicitly answer No)

Based on the code, the app does **NOT** collect or transmit any of:

- Location (precise or approximate)
- Contacts
- Personal info: name, email address, user IDs (beyond the local API token),
  address, phone number, race/ethnicity, political/religious beliefs, sexual
  orientation
- Financial info (no payment info, no purchase history)
- Health & fitness data
- Photos / videos
- Calendar / SMS / call logs
- Web browsing history
- Installed apps inventory — see the Windows note below
- **Device or other identifiers** (advertising ID, etc.) — no ad/analytics SDKs
- **Crash logs / diagnostics / analytics** — no crash-reporting or analytics SDK
  is integrated

> Note on media projection: the Android app captures **audio only** through
> `AudioPlaybackCaptureConfiguration`. It never creates a `VirtualDisplay` or
> reads screen content, so "Photos and videos" stays **No** even though the
> user sees Android's *screen-capture* consent dialog.

> Note on the Windows microphone-usage monitor (`mic_monitor.dart`): the
> **Windows** build polls the registry to learn which applications are using
> the microphone and keeps a local list of up to 30 recently seen application
> names. That is not in the Android app at all (`createMicMonitor` returns a
> no-op off Windows), it is read locally, and it is never transmitted, so it is
> **not** "collected" in Play's sense and does not change the "Installed apps"
> answer. It is disclosed in the policy so the hosted policy and this form
> stay consistent.

> Note on `READ_PHONE_STATE`: the app reads call **state** (ringing/idle/offhook)
> to trigger an upload scan when a call ends. It does **not** read the phone
> number, call log, or any identifier, and does not transmit phone state
> anywhere. So this does not add a "collected" data type — but be ready to
> explain it in the sensitive-permission declaration (see `checklist.md`).

---

## Section D — Security practices (the "Security practices" sub-section)

| Question | Draft answer | Note |
|---|---|---|
| Is data encrypted in transit? | **Conditional** | Only if the user's server uses HTTPS; cleartext HTTP is permitted for LAN/self-hosted. See Section A note — recommend honest "not guaranteed". **CONFIRM.** |
| Can users request data deletion? | **Yes** | On their own server/device; no developer-held data. |
| Committed to Play Families Policy? | **No / N/A** | Not a children's app. |
| Independent security review? | **No** | None performed. |

---

## Section E — Free-text explanation (paste into the form / privacy policy)

> Speakr is a client for a user-self-hosted Speakr transcription server. All
> audio recordings and associated metadata are transmitted only to the server
> URL the user configures; the developer operates no backend and never receives
> user data. Recordings can include the microphone and, when the user turns it
> on for a session and accepts Android's consent dialog, audio played by other
> apps (which may include other call participants); only audio is captured,
> never screen content. Auto-upload sends audio files from folders the user
> selected and then deletes the local file after the server confirms the upload,
> and deletes files shorter than a user-set minimum duration without uploading
> them. The server URL and API token are stored locally in the device's
> encrypted OS secure storage and are sent only to the user's own server for
> authentication. The app integrates no analytics, advertising, or third-party
> tracking. Data deletion is performed by the user on their own server or device.

---

## Items to CONFIRM before submitting (do not guess on the form)

1. **Encryption in transit** — the app allows cleartext HTTP
   (`usesCleartextTraffic="true"`) for self-hosted/LAN servers. Decide whether
   to (a) answer "not all data is encrypted in transit" honestly, or
   (b) enforce HTTPS in a future build so you can truthfully check the box.
   **This is the single most important answer to get right.**
2. **"Shared" vs. "Collected"** — this draft treats the user's own server as the
   user's designated destination (Collected, not Shared with a third party).
   Re-read Play's current definition of "third party"; if Google considers the
   self-hosted server a third party in your interpretation, you may need to mark
   audio/metadata as **Shared**. When unsure, the more conservative answer
   (declare it) is safer.
3. **Transcripts/summaries** — confirm whether server-generated content fetched
   back to the app needs to be declared as a collected data type, per Play's
   latest definitions.
4. **Privacy policy URL** — the policy text is final in `privacy-policy.md`
   and published as `site/privacy-policy.html` (generated; CI checks the two
   match). The URL goes live once GitHub Pages is enabled — see
   `checklist.md`. The Data Safety answers above were reconciled against the
   2026-09-22 policy text; re-check them if the policy changes again.
