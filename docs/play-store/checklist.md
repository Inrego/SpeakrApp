# Google Play — Publishing Checklist

A pre-flight list to get Speakr (`com.inrego.speakr_app`) onto the Play Store.
**To actually fill the Console, work from
[`SUBMISSION-RUNBOOK.md`](SUBMISSION-RUNBOOK.md)** — it carries the paste-ready
answers, including the two settled decisions (App access via the permanently
hosted demo server `https://speakr-demo.renescott.dk`; encryption in transit
answered **No**). This file is the
inventory and the status board behind it.

Items marked **BLOCKER** must be done before the app can be submitted. Items
marked **REVIEW RISK** can be submitted but may trigger extra review or
rejection — read the permissions section carefully. The ready-to-paste Console
justification text for every sensitive permission lives in
[`permissions-declaration.md`](permissions-declaration.md).

---

## 1. Store listing assets

| Asset | Spec | Status | Notes |
|---|---|---|---|
| **App icon** | 512 × 512 PNG (32-bit, with alpha), ≤1 MB | **DONE** | [`assets/icon-512.png`](assets/icon-512.png) — 512 × 512 RGBA, 8.4 KB. Regenerate with `dart run tools/build_store_graphics.dart` (downscales `assets/icon/icon.png`). |
| **Feature graphic** | 1024 × 500 PNG or JPG (no alpha) | **DONE** | [`assets/feature-graphic-1024x500.png`](assets/feature-graphic-1024x500.png) — 1024 × 500, RGB (**verified no alpha channel**). The `speakr-mark-square.svg` mark centered on `#FAFAF7`. Regenerate with `dart run tools/build_store_graphics.dart`. |
| **Phone screenshots** | ≥2 (min 2, max 8), 16:9 or 9:16, each side 320–3840 px | **DONE** | Five distinct screens in [`../screenshots/`](../screenshots/): `mobile-onboarding.png`, `mobile-library.png`, `mobile-detail.png`, `mobile-live.png`, `mobile-settings.png`, plus `mobile.png` (= the detail screen) for the README hero. All 1080 × 2400, captured from a profile build on the Medium Phone API 36.1 AVD against [`tools/mock-server`](../../tools/mock-server/README.md). **Watch at upload:** 1080 × 2400 is 20:9 (2.22 : 1), slightly past a strict 2 : 1 reading of the spec — if the Console rejects them, pad or re-capture at 1080 × 1920. |
| **7-inch tablet screenshots** | optional | Optional | Only if you want the app shown as tablet-optimized. |
| **10-inch tablet screenshots** | optional | Optional | Same. |
| **Promo / TV / Wear assets** | n/a | Skip | Not a TV/Wear app. |
| **Short description** | ≤80 chars | DRAFTED | See `listing.md`. |
| **Full description** | ≤4000 chars | DRAFTED | See `listing.md`. |
| **App title** | ≤30 chars | DRAFTED | See `listing.md`. |

Screenshot suggestions (to show real value): Library with status badges,
recording detail (summary + transcript), live recorder, upload form, speaker
review, settings/connection screen.

---

## 2. App content / policy forms (Play Console → App content)

| Form | Required? | Status | Notes |
|---|---|---|---|
| **Privacy policy URL** | **BLOCKER** | **DONE** (still to enter in Console) | Policy text is in `privacy-policy.md`; the published copy is `site/privacy-policy.html`, deployed by `.github/workflows/pages.yml`. **https://inrego.github.io/SpeakrApp/privacy-policy.html is live and returns HTTP 200.** Paste it into App content → Privacy policy (`SUBMISSION-RUNBOOK.md` §3.1). See `listing.md` and `data-safety.md`. |
| **Data Safety form** | **BLOCKER** | **ANSWERS SETTLED** | Paste-ready answers in `SUBMISSION-RUNBOOK.md` §4; the reasoning is in `data-safety.md`. The last open question — "is all data encrypted in transit?" — is settled **No** (2026-09-22), because cleartext HTTP to self-hosted LAN servers is deliberate. Review and submit in Console. |
| **Content rating questionnaire** | **BLOCKER** | TODO | Complete the IARC questionnaire. Expected outcome: **Everyone** — no violence, no sexual content, no gambling. The app does let users record/upload their own audio (user-generated content) but to their own private server, not a public/social feed; answer the UGC questions accordingly (no public sharing within the app). |
| **Target audience & content** | **BLOCKER** | TODO | Target audience: adults (18+) / general; **do NOT** mark as designed for children — the sensitive permissions and self-hosting requirement make this clearly not a kids' app. This keeps you out of the Families policy / Designed for Families program. |
| **News app declaration** | Required answer | TODO | Answer **No** (not a news app). |
| **COVID-19 contact tracing/status** | Required answer | TODO | Answer **No**. |
| **Data safety: government app** | Required answer | TODO | Answer **No**. |
| **Financial features declaration** | Required answer | TODO | Answer **No** (no financial features). |
| **Health apps declaration** | Required answer | TODO | Answer **No** (records audio but is not a health app). |
| **Ads declaration** | **BLOCKER** | TODO | Answer **No ads** — verified: no ad SDKs in `pubspec.yaml`. |
| **App access (login required)** | **BLOCKER** | **APPROACH SETTLED**, still to fill | The app requires a Speakr server URL + API token to do anything useful, and a reviewer cannot supply either. **Decided 2026-09-25** (superseding the 2026-09-22 Cloudflare quick tunnel): `tools/mock-server` runs permanently as a Docker container on an Oracle arm64 VPS behind Caddy at **`https://speakr-demo.renescott.dk`**; give the reviewer that URL (no trailing slash) plus `speakr-demo-token`. Nothing to start and nothing to tear down. Full steps and paste text: `SUBMISSION-RUNBOOK.md` §2. **Do App access first — it gates Target audience, which gates Data safety (§2.6).** |

---

## 3. Release setup (Play Console → Production / Testing track)

| Item | Status | Notes |
|---|---|---|
| **App signing** | TODO | Enroll in **Play App Signing**. Upload an AAB signed with your upload key (the keystore from CI secrets: `ANDROID_KEYSTORE_*`). Google re-signs with the app signing key. |
| **App bundle (AAB)** | Produced by CI | The release workflow builds an AAB; upload it to the chosen track. |
| **Universal APK** | Produced by CI | For direct GitHub download only — **not** uploaded to Play. |
| **Version code** | Auto (CI) | `versionCode` = GitHub Actions run number. Each Play upload needs a higher `versionCode` than the last. |
| **Pre-launch report** | Auto after upload | Will flag cleartext traffic and permissions; expect notes (see §4). |
| **Countries / regions** | TODO | Select availability. |
| **Pricing** | TODO | Free (no IAP detected). |

---

## 4. SENSITIVE / RESTRICTED PERMISSIONS — read before submitting

These come straight from `android/app/src/main/AndroidManifest.xml`, which
declares **nine** permissions as of 2026-09-22. Each row notes the likely Play
requirement. The former rejection risk — All files access — **was removed** from
the app in #4; see the first entry. Four more permissions were removed in the
permission audit (#7): `READ_MEDIA_AUDIO`, `READ_EXTERNAL_STORAGE`,
`FOREGROUND_SERVICE_DATA_SYNC` and `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`. Rows
for removed permissions are kept, marked 🟢 REMOVED, so the record of what was
once declared stays readable — **none of them needs a Console declaration.**

### 🟢 `MANAGE_EXTERNAL_STORAGE` — "All files access" — REMOVED, migrated to SAF

- **Decision (2026-09-22, superseding the same-day "declare and defend"):**
  the permission is **removed** and Android auto-upload moves to the Storage
  Access Framework — the user picks each watched folder with
  `ACTION_OPEN_DOCUMENT_TREE`, the app persists that grant and scans, reads,
  and deletes within the tree without further prompts. **No restricted
  permission declaration is submitted and no demo video is needed.** The
  earlier decision rested on a false claim about SAF; the history is in
  [`../RELEASE_READINESS.md`](../RELEASE_READINESS.md) item (c) and the
  withdrawn justification in
  [`permissions-declaration.md`](permissions-declaration.md) §1.
- **Code status: shipped.** The removal merged in **#4** on 2026-09-22. The
  manifest no longer declares the permission and
  `lib/features/auto_upload/auto_upload_settings_screen.dart` no longer requests
  it. What remains is build provenance: **do not upload an AAB built before #4**
  — the Console reads the bundle, not the repo, and will block the release until
  a declaration is filed that we deliberately do not provide. Rebuild instead.
- **Play requirement after the migration:** none. A SAF grant is a per-folder
  URI permission, not a manifest permission, and needs no Console form.

### 🟠 `RECORD_AUDIO` (microphone) — declaration + prominent disclosure

- Core feature (live recording). Allowed, but you must:
  - Provide a **prominent in-app disclosure** before first recording (the app
    requests mic via `permission_handler`).
  - Declare microphone use accurately in **Data Safety** (audio is collected and
    transmitted to the user's server).

### 🟠 Foreground service types — FGS declaration required (targetSdk 36)

- Manifest declares `FOREGROUND_SERVICE`,
  `FOREGROUND_SERVICE_MICROPHONE`, `FOREGROUND_SERVICE_MEDIA_PROJECTION`;
  service `.audio.AudioCaptureService` uses
  `foregroundServiceType="mediaProjection|microphone"`.
- **`FOREGROUND_SERVICE_DATA_SYNC` removed 2026-09-22 (permission audit).** The
  app declares no `dataSync` service, and WorkManager runs the auto-upload job
  as ordinary non-expedited work (`lib/main.dart:61`, no `outOfQuotaPolicy`), so
  `androidx.work`'s `SystemForegroundService` is never started and carries no
  `foregroundServiceType` in the merged manifest. Only **two** FGS types now
  need a Console justification.
- **Play requirement:** the **Foreground Service permissions** declaration form
  in the Console requires a justification for each FGS type used on
  targetSdk 34+. `mediaProjection` (capturing other apps' audio) draws extra
  scrutiny and needs a clear use-case description (capturing system/other-app
  audio during a recording session that the user explicitly starts).
- **Status:** must be declared — not an automatic reject if justified. Copy is
  in [`permissions-declaration.md`](permissions-declaration.md) §2–§3 (or
  `SUBMISSION-RUNBOOK.md` §5.2–§5.3). **§4 (`dataSync`) is WITHDRAWN** and must
  not be submitted. `microphone` and `mediaProjection` are two types on the
  **one** service `.audio.AudioCaptureService`.

### 🟠 `READ_PHONE_STATE` — sensitive permission declaration

- Used by `.PhoneStateReceiver` to trigger an auto-upload scan when a phone
  call ends.
- **Play requirement:** phone-state is a sensitive permission and needs a
  justification in the permissions declaration. Confirm **no call-log
  permissions** (`READ_CALL_LOG`/`PROCESS_OUTGOING_CALLS`) are pulled in
  transitively (none declared in the manifest — good). Copy:
  [`permissions-declaration.md`](permissions-declaration.md) §5.

### 🟡 `android:usesCleartextTraffic="true"` — security note (MEDIUM)

- `AndroidManifest.xml:38`. Allows plain HTTP, justified because Speakr is
  self-hosted and may run on `http://` LAN addresses. The **pre-launch report**
  and security reviewers will flag this; that is expected and not a blocker.
  Document the rationale in the Data Safety notes and in your review notes.
  Reviewer-note copy: [`permissions-declaration.md`](permissions-declaration.md)
  §7.
- **This setting is why Data safety answers "encrypted in transit" = No**
  (settled 2026-09-22). Because plain HTTP is an intended, supported path, the
  all-or-nothing box cannot honestly be ticked. See `SUBMISSION-RUNBOOK.md`
  §4.1.

### 🟢 `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` — REMOVED 2026-09-22

- Play discourages directly requesting this, and nothing in the app ever did:
  no `Permission.ignoreBatteryOptimizations` call and no
  `ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` intent anywhere in `lib/` or
  `android/`. It was dead weight from the initial commit.
- **Removed from the manifest in the permission audit (#7).** Nothing to
  declare; [`permissions-declaration.md`](permissions-declaration.md) §6 is
  **WITHDRAWN** and must not be submitted.

### 🟢 Standard / low risk

- `INTERNET`, `WAKE_LOCK`, `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED` —
  standard for a background-upload app; declare where the Console asks, low
  rejection risk. `WAKE_LOCK`, `RECEIVE_BOOT_COMPLETED` and `POST_NOTIFICATIONS`
  are merged in by `androidx.work` / `workmanager_android` regardless of what
  the app manifest says.
- **`READ_MEDIA_AUDIO` and `READ_EXTERNAL_STORAGE` (maxSdkVersion 32) removed
  2026-09-22 (permission audit).** No storage permission of any kind is left.
  On Android every watched-folder file is listed, read and deleted through the
  persisted SAF tree grant (`lib/features/auto_upload/auto_upload_files.dart:180`),
  the folder picker is `ACTION_OPEN_DOCUMENT_TREE`, and no dependency merges
  either permission back in. The app has **no** single-file picker on Android.
- `ACCESS_NETWORK_STATE` appears in the merged manifest but is **not** declared
  by the app: `androidx.work` and `androidx.media3` (just_audio) each contribute
  it. Same for the signature-level
  `com.inrego.speakr_app.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` from
  `androidx.core`. Both are expected; neither needs a declaration.

---

## 5. Pre-submission sanity checks

- [ ] `targetSdk` meets Play's current minimum (the app targets SDK 36 — well
      above the minimum; OK).
- [ ] AAB is signed and uploads without "debug-signed" errors (CI release
      keystore is wired; verify the production build, not a debug build).
- [ ] **App access** form carries `https://speakr-demo.renescott.dk` (no
      trailing slash) and `speakr-demo-token`, with the 313-character
      instructions text — the field caps at 500 (`SUBMISSION-RUNBOOK.md` §2).
      Re-run the §2.2 probes on the day you submit; the endpoint is permanent,
      but its Let's Encrypt certificate expires **2026-12-13**.
- [x] Privacy policy URL is live and reachable —
      **https://inrego.github.io/SpeakrApp/privacy-policy.html**, HTTP 200.
- [ ] Data Safety answers match actual behavior, with **encrypted in transit =
      No** (settled 2026-09-22; see `data-safety.md` Section A).
- [x] Decision recorded on `MANAGE_EXTERNAL_STORAGE` — **removed, migrated to
      SAF**, 2026-09-22 (supersedes the same-day "declare and defend"). History:
      [`../RELEASE_READINESS.md`](../RELEASE_READINESS.md) item (c).
- [x] SAF migration PR merged (**#4**, 2026-09-22) and the permission audit
      merged (**#7**, same day).
- [ ] The AAB being uploaded was built from a commit at or after **#7** — none
      of `MANAGE_EXTERNAL_STORAGE`, `READ_MEDIA_AUDIO`, `READ_EXTERNAL_STORAGE`,
      `FOREGROUND_SERVICE_DATA_SYNC`, `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`
      may appear in the Console's permissions list on upload.
- [x] Screenshots + feature graphic **produced** (§1) — still to be uploaded
      in the Console.
- [ ] Content rating questionnaire submitted (expect Everyone).

---

## 6. Follow-ups requiring your input (cannot be done from the repo)

1. ~~**Write & host the privacy policy**~~ **Done 2026-09-22** — live at
   **https://inrego.github.io/SpeakrApp/privacy-policy.html** (HTTP 200).
   Remaining: paste the URL into the Console.
2. ~~**Capture screenshots** (`docs/screenshots/mobile.png` + more) and the
   **feature graphic**.~~ **Done 2026-09-22** — see §1. Screenshots were
   captured against the local mock server, so no real recordings appear in the
   listing.
3. **Provide reviewer test access** in the App access form. (BLOCKER)
   **Approach decided 2026-09-25**, superseding the 2026-09-22 quick tunnel:
   [`tools/mock-server`](../../tools/mock-server/README.md) is deployed as a
   permanent Docker container on an Oracle arm64 (Ampere A1) VPS, created with
   Dockhand and fronted by Caddy, at **`https://speakr-demo.renescott.dk`**.
   Give the reviewer that URL plus the demo token `speakr-demo-token`; there is
   nothing to start and nothing to tear down. Steps and paste text:
   `SUBMISSION-RUNBOOK.md` §2. The reviewer-runs-it-themselves variant is a
   documented fallback only (runbook Appendix A) and should not be submitted.
4. ~~Decide the `MANAGE_EXTERNAL_STORAGE` strategy for the Play build.~~ **Done
   2026-09-22 — removed and migrated to SAF** (the same-day "declare and
   defend" decision is superseded). The SAF migration merged in #4. Nothing to
   paste and no video to record; just build the Play AAB from #7 or later.
5. **Enroll in Play App Signing** and upload the production AAB.
6. Complete every "App content" form (rating, target audience, ads, news,
   financial, health, government).
7. ~~Decide how the reviewer reaches a server, and how to answer "encrypted in
   transit".~~ **Both done** — the hosted demo endpoint (item 3, settled
   2026-09-25) and **No** (the Data Safety row in §2, settled 2026-09-22). No
   open decisions remain in the submission docs.
