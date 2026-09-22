# Play Console — Permissions Declaration Copy

Ready-to-paste justification text for the Play Console declaration forms, one
section per form Google asks for. Written in the first person, as the developer
filling in the Console.

Recorded decision on storage (supersedes the 2026-09-22 "declare and defend"
entry): **`MANAGE_EXTERNAL_STORAGE` is being removed** and Android auto-upload
is migrating to the Storage Access Framework. **No All-files-access
declaration will be submitted.** §1 below records why, and what the earlier
justification got wrong. See [`../RELEASE_READINESS.md`](../RELEASE_READINESS.md)
item (c) for the decision history.

The code change (manifest, runtime request, worker) lands in a **separate PR**.
Until it merges, `android/app/src/main/AndroidManifest.xml:13` still declares
the permission and `lib/features/auto_upload/auto_upload_settings_screen.dart`
still requests it. Do not upload an AAB built from that state to Play: the
Console will detect the permission in the bundle and demand the declaration
this document no longer provides.

Every factual claim in §2–§7 was checked against
`android/app/src/main/AndroidManifest.xml` and `lib/features/auto_upload/`.
Two corrections against earlier drafts of the checklist are noted inline
(§3 and §5) — read them before pasting.

---

## 1. All files access (`MANAGE_EXTERNAL_STORAGE`) — REMOVED, no declaration

**Form:** Play Console → App content → **Sensitive app permissions** →
*Permissions declaration form* → **All files access permission** — **do not
fill in.** Since the SAF migration landed (#4) the AAB no longer contains the permission and
the Console will not ask for this form.

**What replaces it:** the Storage Access Framework. The user picks each
watched folder with Android's own picker (`ACTION_OPEN_DOCUMENT_TREE`); the
app takes a persistable URI permission on that tree
(`takePersistableUriPermission`) and thereafter lists, reads, and **deletes**
documents inside it through `DocumentsContract` / `DocumentFile`. No further
prompt is involved: a persisted tree grant lets the holder delete other apps'
files in that subtree, from a background worker, with the screen off. That is
exactly the unattended delete-after-upload flow — it never needed All files
access.

**Why the earlier justification was withdrawn, not just dropped:** the
"declare and defend" text asserted that neither the Storage Access Framework
nor MediaStore can delete a file written by another app without the system
asking the user to confirm each individual deletion. That is true of the
MediaStore path (its delete-request dialog) and **false of SAF**. The
confirm-each-deletion dialog is MediaStore's mechanism; a SAF tree grant has
no such dialog. The whole case for the restricted permission rested on
that error, so the case is withdrawn. Submitting it would have asked Google to
approve a restricted permission on a false premise.

Two further points the earlier text leaned on, corrected for the record:

- **`Android/data` is not an argument for the permission.** On Android 11+
  a recorder's private `Android/data/<pkg>/` output is unreachable by raw path
  *even with* `MANAGE_EXTERNAL_STORAGE`, and the SAF picker refuses to grant
  `Android/data` or `Android/obb` trees. Recorders that write there are out of
  reach either way; the permission bought nothing for them.
- **`READ_MEDIA_AUDIO` alone not seeing arbitrary folders** is still true, but
  it argues for SAF, not for All files access: a SAF grant covers whatever
  folder the user picked regardless of media collection membership.

**What the SAF grant does and does not cover (for the reviewer, if asked):**
the app can enumerate, read, and delete files only within the trees the user
picked; it cannot see or touch anything else on external storage; and the user
can revoke a grant by removing the folder in Auto-upload settings (which calls
`releasePersistableUriPermission`, `packages/speakr_saf/android/src/main/kotlin/com/inrego/speakr_saf/SpeakrSafPlugin.kt:107`)
or by uninstalling. This is narrower than
All files access on every axis and is what the public privacy policy now
describes under "Auto-upload, folder access, and deletion of your files".

**No demo video is required** — the video was an artefact of the restricted
permission form.

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

> This is used to capture device audio — the other side of a video meeting or
> VoIP call, or any media the device is playing — alongside the microphone, so
> the transcript contains both sides rather than only the person holding the
> phone. Android exposes system audio capture only through `MediaProjection`
> (`AudioPlaybackCaptureConfiguration`), so it is the only API that produces a
> usable two-sided recording. The capture is limited to what Android makes
> available to that API: streams tagged `USAGE_MEDIA`, `USAGE_GAME`, and
> `USAGE_UNKNOWN`. Apps that opt out of playback capture, and ordinary
> telephony audio, are excluded by the platform.
>
> Capture is user-initiated per session and never persists. Each time the user
> starts a system-audio recording, Android shows its own screen-capture consent
> dialog, launched by the app via `MediaProjectionManager.createScreenCaptureIntent()`;
> recording only proceeds if the user approves that dialog, and the projection is
> released when the session ends. No consent is cached or reused across sessions.
> The app captures audio only — it never reads, stores, or transmits screen
> pixels. The captured audio goes to one destination: the user's own self-hosted
> Speakr server, at a URL the user entered. It is not sent to me, to any
> third-party service, or to any analytics or advertising SDK. The app's public
> privacy policy discloses this capture, including that other call participants
> may be recorded, under "Recording other apps' audio".

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

## 8. Remaining storage-related risk

With `MANAGE_EXTERNAL_STORAGE` gone there is no restricted storage permission
left to declare, so the "declaration may be denied" risk recorded on 2026-09-22
no longer exists. What remains is sequencing: the Play AAB must be built from a
commit at or after the SAF migration (#4). An AAB that still carries the permission is
flagged by the Console at upload and cannot be published without the
declaration §1 no longer provides. `READ_MEDIA_AUDIO` (manual file picking) is
an ordinary runtime permission and needs no form. The sideload APK and the
Windows builds are unaffected.
