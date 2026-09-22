# Play Console — Permissions Declaration Copy

Ready-to-paste justification text for the Play Console declaration forms, one
section per form Google asks for. Written in the first person, as the developer
filling in the Console.

Recorded decision: **option 3, "declare and defend"** (see
[`../RELEASE_READINESS.md`](../RELEASE_READINESS.md) item (c)) — dated
**2026-09-22**. `MANAGE_EXTERNAL_STORAGE` stays declared in the manifest and
requested at runtime; no code, manifest, or gradle change accompanies this
document.

Every factual claim below was checked against
`android/app/src/main/AndroidManifest.xml` and `lib/features/auto_upload/`.
Two corrections against earlier drafts of the checklist are noted inline
(§3 and §5) — read them before pasting.

---

## 1. Restricted permission declaration — All files access (`MANAGE_EXTERNAL_STORAGE`)

**Form:** Play Console → App content → **Sensitive app permissions** →
*Permissions declaration form* → **All files access permission**

**Permission:** `android.permission.MANAGE_EXTERNAL_STORAGE`
(`android/app/src/main/AndroidManifest.xml:13`)

**Core functionality this permission enables:** automatic upload of recordings
produced by *other* apps, followed by deletion of the local copy.

**Justification (paste into the free-text field):**

> Speakr is a client for a self-hosted transcription server — the user runs the
> server themselves and the app talks only to that server. Its auto-upload
> feature is the reason I need All files access.
>
> The user picks one or more folders on the device with the system directory
> picker. Those folders are written by *other* apps — call recorders, voice
> recorders, dictation apps — which place their output in arbitrary, app-chosen
> locations outside any shared media collection. The app periodically scans the
> chosen folders, uploads any new audio file to the user's own server, and then
> **deletes the local copy** so that a device recording calls all day does not
> fill its storage. Delete-after-upload is the feature; without it the folder
> grows without bound and the user has to clean up by hand after every call.
>
> Narrower APIs do not serve this. The Storage Access Framework and MediaStore
> cannot delete a file written by another app without a per-file system consent
> prompt (`MediaStore.createDeleteRequest`), which the user must tap for every
> single file. The uploads run unattended in the background — they are triggered
> by a periodic background job and by the end of a phone call, often while the
> screen is off — so a per-file consent dialog cannot be answered and the
> unattended flow breaks down entirely. The recorded folders also frequently sit
> outside the audio media collection, so `READ_MEDIA_AUDIO` alone does not even
> let the app see the files, let alone remove them.
>
> The access is confined to that feature. The app does not browse, index, or
> transmit anything outside the folders the user explicitly selected; it reads
> the audio file, uploads it to the user's own server, deletes it, and stores
> nothing else. There is no third-party backend and no advertising SDK.

**Evidence to cite if the reviewer asks (also listed in RELEASE_READINESS item (c)):**

| Claim | File:line |
|---|---|
| Permission declared | `android/app/src/main/AndroidManifest.xml:13` |
| Requested at runtime | `lib/features/auto_upload/auto_upload_settings_screen.dart:691` (`Permission.manageExternalStorage`) |
| In-app rationale shown to the user | `lib/features/auto_upload/auto_upload_settings_screen.dart:765-767` — *"All files access — to delete recordings after successful upload."* |
| Folder chosen by the user, not the app | `lib/features/auto_upload/auto_upload_settings_screen.dart:64,240` — `FilePicker.getDirectoryPath()` |
| Plain-filesystem scan of that folder | `lib/features/auto_upload/auto_upload_worker.dart:76-81` — `listCandidateFiles()` → `Directory(folderPath).listSync(followLinks: false)` |
| Delete of the local copy after a successful upload | `lib/features/auto_upload/auto_upload_worker.dart:396-415` (`deleteLocalAutoUploadFile`), called at `:482` |
| Unattended trigger — periodic background job | `lib/main.dart:62-69` — WorkManager periodic task, 15-minute cadence |
| Unattended trigger — end of a phone call | `android/app/src/main/kotlin/com/inrego/speakr_app/PhoneStateReceiver.kt` |

**Video demo (the form asks for one):** record a short screen capture showing
Auto-upload settings → pick folder → a recording appearing in the folder → the
app uploading it → the local file disappearing. Upload it unlisted to YouTube
and paste the link.

---

## 2. Foreground service type — Microphone

**Form:** Play Console → App content → **Foreground service permissions** →
*Microphone*

**Permission / type:** `android.permission.FOREGROUND_SERVICE_MICROPHONE`
(manifest line 5); service `.audio.AudioCaptureService` declared with
`android:foregroundServiceType="mediaProjection|microphone"`
(`AndroidManifest.xml:65-68`).

**Justification:**

> Speakr records meetings and calls so they can be transcribed on the user's own
> server. Recording is started explicitly by the user from the in-app recorder
> screen, and a session can easily run for an hour. The microphone foreground
> service keeps the capture alive while the user switches to another app, or
> while the screen is off, and keeps a persistent notification on screen for the
> whole session so it is always obvious that recording is in progress. Without
> the foreground service the capture is killed as soon as the app leaves the
> foreground and the user loses the meeting. There is no recording without an
> explicit user action; the service is started when recording starts and stopped
> when recording stops.

---

## 3. Foreground service type — Media projection

**Form:** Play Console → App content → **Foreground service permissions** →
*Media projection*

**Permission / type:** `android.permission.FOREGROUND_SERVICE_MEDIA_PROJECTION`
(manifest line 6); same service `.audio.AudioCaptureService`.

**Justification:**

> This is used to capture device audio — the other side of a call or a video
> meeting — alongside the microphone, so the transcript contains both speakers
> rather than only the person holding the phone. Android exposes system audio
> capture only through `MediaProjection`, so it is the only API that produces a
> usable two-sided recording.
>
> Capture is user-initiated per session and never persists. Each time the user
> starts a system-audio recording, Android shows its own screen-capture consent
> dialog, launched by the app via `MediaProjectionManager.createScreenCaptureIntent()`;
> recording only proceeds if the user approves that dialog, and the projection is
> released when the session ends. No consent is cached or reused across sessions.
> The app captures audio only — it never reads, stores, or transmits screen
> pixels. The captured audio goes to one destination: the user's own self-hosted
> Speakr server, at a URL the user entered. It is not sent to me, to any
> third-party service, or to any analytics or advertising SDK.

*Correction against the earlier checklist wording:* the microphone and media
projection types are two declarations for **one** service, `.audio.AudioCaptureService`,
which carries `foregroundServiceType="mediaProjection|microphone"` — they are not
separate services.

---

## 4. Foreground service type — Data sync

**Form:** Play Console → App content → **Foreground service permissions** →
*Data sync*

**Permission / type:** `android.permission.FOREGROUND_SERVICE_DATA_SYNC`
(manifest line 7).

**Justification:**

> Auto-upload transfers audio files from folders the user selected to the user's
> own Speakr server. The work is scheduled with Android's WorkManager — a
> periodic job plus a one-shot job enqueued when a phone call ends — and a
> recording can be a long file over a slow uplink, so WorkManager may need to run
> the transfer as a data-sync foreground service to finish it without being
> killed mid-upload. The notification tells the user an upload is in progress.
> The only network destination is the server URL the user configured; nothing is
> synced anywhere else.

*Correction against the earlier checklist wording:* the app itself declares **no**
service with `foregroundServiceType="dataSync"`. The only app-declared service is
`.audio.AudioCaptureService` (mediaProjection|microphone). The `DATA_SYNC`
permission backs `androidx.work.impl.foreground.SystemForegroundService`, which
the WorkManager library merges into the manifest and which sets its type at
runtime. If the Console form asks which service uses the type, name the
WorkManager system foreground service. If the reviewer pushes back on an unused
type, the honest answer is that it covers WorkManager's expedited/long-running
upload path; it can be dropped from the manifest later if measurements show
WorkManager never takes it.

---

## 5. Sensitive permission — `READ_PHONE_STATE`

**Form:** Play Console → App content → **Sensitive app permissions** (phone
permission group), and the review notes.

**Permission:** `android.permission.READ_PHONE_STATE`
(`AndroidManifest.xml:11`).

**Justification:**

> A large part of Speakr's audience uses it with a call-recorder app. Those apps
> finish writing a recording when the call ends, so the app listens for the phone
> state going from off-hook to idle and, about 40 seconds later, enqueues a
> single background scan of the user's watched folders. That is the entire use:
> a timing signal that says "a new recording may have just landed on disk, go
> look". Polling on a timer instead would either miss recordings for up to
> fifteen minutes or waste battery scanning constantly.
>
> The app reads only the call state broadcast. It does not read the phone number,
> the subscriber identity, the device identifiers, or the call log — no call-log
> permissions (`READ_CALL_LOG`, `PROCESS_OUTGOING_CALLS`) are declared anywhere in
> the manifest — and it does not record calls itself.

**Evidence:** `android/app/src/main/kotlin/com/inrego/speakr_app/PhoneStateReceiver.kt`
(off-hook → idle transition enqueues a WorkManager one-shot);
`AndroidManifest.xml:53-60` (receiver registration).

---

## 6. `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`

**Form:** review notes / policy questionnaire if prompted.

**Permission:** `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`
(`AndroidManifest.xml:18`).

**Justification:**

> Auto-upload has to run in the background on a schedule; on several OEM Android
> builds, aggressive battery management stops the background job from ever firing
> and recordings pile up on the device unseen. The permission is declared so the
> app can offer the user the standard system exemption dialog when that happens.
> Any exemption is granted by the user in that system dialog; the app cannot and
> does not grant it silently.

**⚠️ Correction — verify before submitting.** The permission is declared in the
manifest but **no code currently requests it**: there is no
`Permission.ignoreBatteryOptimizations` call and no
`ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` intent anywhere in `lib/` or
`android/` (grep is clean). So the "user-initiated flow" the checklist assumes
does not exist yet. Two honest options before submitting:

1. **Remove the permission** from the manifest — nothing uses it today. This is
   the cleanest answer and removes a policy note for free.
2. **Wire the request** behind a user-tapped button in Auto-upload settings, then
   paste the justification above as written.

Do not paste §6 as-is while neither is true.

---

## 7. Review notes — `usesCleartextTraffic="true"`

**Form:** Play Console → the release's **review notes** field (and worth
repeating in the Data Safety notes).

**Setting:** `android:usesCleartextTraffic="true"` on `<application>`
(`AndroidManifest.xml:23`).

**Note to the reviewer:**

> Speakr talks to a server the user hosts themselves and enters the URL for at
> first run. In practice a large share of those servers run on a home or office
> LAN at a plain `http://` address with no TLS certificate — a self-signed
> certificate would be worse for the user than plain HTTP on their own network.
> If the app refused cleartext, those users could not connect at all. Cleartext
> is therefore enabled app-wide by design, not by oversight. The app ships no
> hard-coded server and contacts no backend of mine; the only host it talks to is
> the one the user typed in. A future release may narrow this to a
> `network_security_config.xml` that permits cleartext only for the
> user-configured host.

---

## 8. Accepted risk

The declaration route was chosen with eyes open. All files access is restricted
to a short list of app categories, and a transcription/upload client is not on
that list, so Google may deny the declaration. If that happens, the documented
fallbacks are still on the table — scope down to `READ_MEDIA_AUDIO` + SAF with
per-file delete consent, or strip `MANAGE_EXTERNAL_STORAGE` from the Play AAB and
keep it only in the sideloaded APK. Both are described in
[`../RELEASE_READINESS.md`](../RELEASE_READINESS.md) item (c). The sideload APK
and the Windows builds are unaffected either way.
