# Google Play — Publishing Checklist

A pre-flight list to get Speakr (`com.inrego.speakr_app`) onto the Play Store.
Items marked **BLOCKER** must be done before the app can be submitted. Items
marked **REVIEW RISK** can be submitted but may trigger extra review or
rejection — read the permissions section carefully. The ready-to-paste Console
justification text for every sensitive permission lives in
[`permissions-declaration.md`](permissions-declaration.md).

---

## 1. Store listing assets

| Asset | Spec | Status | Notes |
|---|---|---|---|
| **App icon** | 512 × 512 PNG (32-bit, with alpha), ≤1 MB | TODO | Source: `assets/icon/icon.png` is 1024×1024 — downscale to 512×512. Play renders its own rounded mask; supply a square. |
| **Feature graphic** | 1024 × 500 PNG or JPG (no alpha) | TODO (**BLOCKER** — required for the listing) | Does not exist yet. Build from the brand mark `speakr-mark-square.svg` on the off-white `#FAFAF7` background. |
| **Phone screenshots** | ≥2 (min 2, max 8), 16:9 or 9:16, each side 320–3840 px | TODO (**BLOCKER**) | Capture from a phone build. Reference asset path in repo: `docs/screenshots/mobile.png` (capture this and additional screens). At least 2 distinct screens required. |
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
| **Privacy policy URL** | **BLOCKER** | TODO | Must host a public policy and enter the URL. Does not exist. See `listing.md` and `data-safety.md`. |
| **Data Safety form** | **BLOCKER** | DRAFTED | First-draft answers in `data-safety.md`. Review and submit in Console. |
| **Content rating questionnaire** | **BLOCKER** | TODO | Complete the IARC questionnaire. Expected outcome: **Everyone** — no violence, no sexual content, no gambling. The app does let users record/upload their own audio (user-generated content) but to their own private server, not a public/social feed; answer the UGC questions accordingly (no public sharing within the app). |
| **Target audience & content** | **BLOCKER** | TODO | Target audience: adults (18+) / general; **do NOT** mark as designed for children — the sensitive permissions and self-hosting requirement make this clearly not a kids' app. This keeps you out of the Families policy / Designed for Families program. |
| **News app declaration** | Required answer | TODO | Answer **No** (not a news app). |
| **COVID-19 contact tracing/status** | Required answer | TODO | Answer **No**. |
| **Data safety: government app** | Required answer | TODO | Answer **No**. |
| **Financial features declaration** | Required answer | TODO | Answer **No** (no financial features). |
| **Health apps declaration** | Required answer | TODO | Answer **No** (records audio but is not a health app). |
| **Ads declaration** | **BLOCKER** | TODO | Answer **No ads** — verified: no ad SDKs in `pubspec.yaml`. |
| **App access (login required)** | **BLOCKER** | TODO | The app requires a Speakr server URL + API token to do anything useful. Play reviewers cannot supply these, so you **must provide test credentials / a demo server** OR detailed instructions in the "App access" → "All or some functionality is restricted" section, otherwise the review will fail because the reviewer can't get past the connection screen. **This is a common rejection cause — fill it in.** |

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

These come straight from `android/app/src/main/AndroidManifest.xml`. Each row
notes the likely Play requirement. The first one is a genuine rejection risk.

### 🟠 `MANAGE_EXTERNAL_STORAGE` — "All files access" — DECIDED: declare and defend

- **Decision (2026-09-22):** keep the permission and **submit the restricted
  permission declaration** — option 3. Ready-to-paste Console copy, with the
  file:line evidence a reviewer may ask for, is in
  [`permissions-declaration.md`](permissions-declaration.md) §1. See
  [`../RELEASE_READINESS.md`](../RELEASE_READINESS.md) item (c) for the recorded
  decision and the accepted risk.
- **Where:** manifest line 13; requested at runtime in
  `lib/features/auto_upload/auto_upload_settings_screen.dart:691` (rationale shown
  to the user at `:765-767`: "All files access — to delete recordings after
  successful upload").
- **Play requirement:** All-files access is a **restricted permission**. Google
  Play allows it only for a narrow set of app categories (file managers, backup,
  antivirus, document management, on-device file search, etc.). A
  transcription/upload client is not on that list, so the declaration triggers a
  permission-use review and **may be denied** — an accepted risk, not a solved
  problem. The declaration form also asks for a demo video; see
  [`permissions-declaration.md`](permissions-declaration.md) §1 for what to record.
- **Fallbacks if the declaration is denied** (both still documented, neither
  implemented):
  1. Drop `MANAGE_EXTERNAL_STORAGE` and use scoped access — `READ_MEDIA_AUDIO` for
     reading + SAF / `MediaStore.createDeleteRequest()` for per-file consented
     deletion. Costs the unattended delete-after-upload flow.
  2. Keep `MANAGE_EXTERNAL_STORAGE` **only** in the sideload/direct-download APK
     and strip it from the Play AAB via a manifest placeholder or build flavor.

### 🟠 `RECORD_AUDIO` (microphone) — declaration + prominent disclosure

- Core feature (live recording). Allowed, but you must:
  - Provide a **prominent in-app disclosure** before first recording (the app
    requests mic via `permission_handler`).
  - Declare microphone use accurately in **Data Safety** (audio is collected and
    transmitted to the user's server).

### 🟠 Foreground service types — FGS declaration required (targetSdk 36)

- Manifest declares `FOREGROUND_SERVICE`,
  `FOREGROUND_SERVICE_MICROPHONE`, `FOREGROUND_SERVICE_MEDIA_PROJECTION`,
  `FOREGROUND_SERVICE_DATA_SYNC`; service `.audio.AudioCaptureService` uses
  `foregroundServiceType="mediaProjection|microphone"`.
- **Play requirement:** the **Foreground Service permissions** declaration form
  in the Console requires a justification for each FGS type used on
  targetSdk 34+. `mediaProjection` (capturing other apps' audio) draws extra
  scrutiny and needs a clear use-case description (capturing system/other-app
  audio during a recording session that the user explicitly starts).
- **Status:** must be declared — not an automatic reject if justified. Copy for
  all three types is in [`permissions-declaration.md`](permissions-declaration.md)
  §2–§4. Note that `microphone` and `mediaProjection` are two types on the **one**
  service `.audio.AudioCaptureService`, and that the app declares no `dataSync`
  service of its own — that type backs WorkManager's own foreground service.

### 🟠 `READ_PHONE_STATE` — sensitive permission declaration

- Used by `.PhoneStateReceiver` to trigger an auto-upload scan when a phone
  call ends.
- **Play requirement:** phone-state is a sensitive permission and needs a
  justification in the permissions declaration. Confirm **no call-log
  permissions** (`READ_CALL_LOG`/`PROCESS_OUTGOING_CALLS`) are pulled in
  transitively (none declared in the manifest — good). Copy:
  [`permissions-declaration.md`](permissions-declaration.md) §5.

### 🟡 `android:usesCleartextTraffic="true"` — security note (MEDIUM)

- Manifest line 23. Allows plain HTTP, justified because Speakr is self-hosted
  and may run on `http://` LAN addresses. The **pre-launch report** and security
  reviewers will flag this. Document the rationale in the Data Safety notes and
  in your review notes; it is allowed but noted. Reviewer-note copy:
  [`permissions-declaration.md`](permissions-declaration.md) §7.

### 🟡 `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` (LOW–MEDIUM)

- Play discourages directly requesting this. Generally allowed for legitimate
  background-upload reliability, but may draw a policy note.
- **Verified 2026-09-22: nothing in the app requests it.** The permission is
  declared in the manifest (line 18) but there is no
  `Permission.ignoreBatteryOptimizations` call and no
  `ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` intent in `lib/` or `android/`.
  Either remove it from the manifest or wire a user-tapped request before
  submitting — see [`permissions-declaration.md`](permissions-declaration.md) §6.

### 🟢 Standard / low risk

- `INTERNET`, `WAKE_LOCK`, `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`,
  `READ_MEDIA_AUDIO`, `READ_EXTERNAL_STORAGE` (maxSdkVersion 32),
  `FOREGROUND_SERVICE_DATA_SYNC` — standard for a background-upload app; declare
  where the Console asks, low rejection risk.

---

## 5. Pre-submission sanity checks

- [ ] `targetSdk` meets Play's current minimum (the app targets SDK 36 — well
      above the minimum; OK).
- [ ] AAB is signed and uploads without "debug-signed" errors (CI release
      keystore is wired; verify the production build, not a debug build).
- [ ] App opens to the connection screen and the **App access** form gives the
      reviewer working test credentials or a demo Speakr server.
- [ ] Privacy policy URL is live and reachable.
- [ ] Data Safety answers match actual behavior (see `data-safety.md`).
- [x] Decision recorded on `MANAGE_EXTERNAL_STORAGE` — **declare and defend**,
      2026-09-22. Declaration copy: [`permissions-declaration.md`](permissions-declaration.md);
      rationale and accepted risk: [`../RELEASE_READINESS.md`](../RELEASE_READINESS.md) item (c).
- [ ] Restricted-permission declaration form actually submitted in the Console
      (paste §1, attach the demo video).
- [ ] Screenshots + feature graphic uploaded.
- [ ] Content rating questionnaire submitted (expect Everyone).

---

## 6. Follow-ups requiring your input (cannot be done from the repo)

1. **Write & host the privacy policy** → paste URL into Console. (BLOCKER)
2. **Capture screenshots** (`docs/screenshots/mobile.png` + more) and the
   **feature graphic**. (BLOCKER)
3. **Provide reviewer test access** (demo server + token, or instructions) in
   the App access form. (BLOCKER)
4. ~~Decide the `MANAGE_EXTERNAL_STORAGE` strategy for the Play build.~~ **Done
   2026-09-22 — declare and defend.** Remaining: paste
   [`permissions-declaration.md`](permissions-declaration.md) §1 into the
   restricted-permission declaration and record the demo video.
5. **Enroll in Play App Signing** and upload the production AAB.
6. Complete every "App content" form (rating, target audience, ads, news,
   financial, health, government).
