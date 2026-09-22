# Release Readiness Report

Pre-release checklist for maintainers. This is an engineering / risk report, not
marketing copy. Each item lists **severity**, **what it affects**, the **evidence**
(file references), and the **recommended action**. Nothing here changes app
behavior — items marked as actions are decisions for the maintainer to make before
shipping.

App: **Speakr** · package `com.inrego.speakr_app` · pubspec `version: 0.1.0+1`
Targets: Android, iOS, Windows desktop. Versioning is tag-driven via CI
(`vX.Y.Z` → build-name `X.Y.Z`, build-number = `github.run_number`).

Severity legend: **BLOCKER** (fix before that channel can ship) · **HIGH** ·
**MEDIUM** · **LOW** (document / monitor).

---

## Summary table

| # | Item | Severity | Affects |
|---|------|----------|---------|
| a | Google Fonts fetched at runtime | **HIGH** | First-launch UX (needs network) |
| b | `android:usesCleartextTraffic="true"` | MEDIUM | Security posture / Play review note |
| c | `MANAGE_EXTERNAL_STORAGE` (All files access) | **BLOCKER (Play)** | Play approval |
| d | iOS unverified — no Mac in CI | MEDIUM | iOS release availability |
| e | Linux not a target | LOW | Scope clarity |
| f | Android debug-signing fallback | MEDIUM | Release-build integrity / Play upload |
| g | Windows build unsigned | MEDIUM | Install UX (SmartScreen) |

---

## (a) Google Fonts fetched at runtime — HIGH

**What:** Runtime font fetching is explicitly enabled. The three brand typefaces
(Inter Tight, Source Serif 4, JetBrains Mono) are loaded via the `google_fonts`
package and are **not bundled as assets**, so first launch needs network access or
the UI silently falls back to system fonts.

**Evidence:**
- `lib/main.dart:59` — `GoogleFonts.config.allowRuntimeFetching = true;`
- `lib/theme/typography.dart:20,36,50` — `GoogleFonts.sourceSerif4(...)`,
  `GoogleFonts.interTight(...)`, `GoogleFonts.jetBrainsMono(...)`.
- `AGENTS.md:26` (Stack table, Fonts row): *"Runtime fetching enabled in
  `main.dart`; bundle TTFs as assets before shipping a release build."*
- `AGENTS.md:78` (pitfall #6): *"Google Fonts runtime fetching is on in
  `main.dart`. First launch needs network, or fonts fall back to system. Before
  shipping a real release, bundle the TTFs."*

**Affects:** UX (cold first launch on a fresh install / offline device renders with
fallback fonts; a self-hosted, possibly-LAN-only user may never have internet for
the font CDN). Also a privacy nuance — first launch reaches out to the Google Fonts
CDN, which contradicts the "no third-party backend" positioning in the store copy.

**Recommended action:** Before a public release, download the TTFs, add them under
`assets/fonts/`, register them in `pubspec.yaml`, and either remove the
`allowRuntimeFetching = true` line or leave it as a fallback. This removes the
network dependency and the third-party CDN call on first launch.

---

## (b) `android:usesCleartextTraffic="true"` — MEDIUM

**What:** The Android app permits plain-HTTP traffic app-wide.

**Evidence:**
- `android/app/src/main/AndroidManifest.xml:23` —
  `android:usesCleartextTraffic="true"` on `<application>`.

**Affects:** Security posture and Play review. This is **justified** for Speakr
because it targets *self-hosted* servers that frequently run on `http://` LAN
addresses (no TLS), so it is intentional, not a bug. However, Play's pre-launch
report and security reviewers flag cleartext, and it widens the attack surface on
untrusted networks.

**Recommended action:** Keep it (the self-hosted/LAN use case requires it), but
document the rationale in the Play data-safety notes and README. Optionally tighten
later with a `network_security_config.xml` that allows cleartext only for
user-configured hosts rather than globally.

---

## (c) `MANAGE_EXTERNAL_STORAGE` / All files access — BLOCKER (Play track)

**What:** The app declares and requests All-files-access. Google Play classifies
`MANAGE_EXTERNAL_STORAGE` as a restricted permission limited to a narrow set of app
categories (file managers, backup, antivirus, etc.). A transcription/upload client
is **likely to be rejected** or to require a special Play Console declaration plus a
permission-use review, and risks removal if the declaration is denied.

**Evidence:**
- Declared: `android/app/src/main/AndroidManifest.xml:13` —
  `<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"/>`.
- Requested at runtime: `lib/features/auto_upload/auto_upload_settings_screen.dart:691`
  — `Permission.manageExternalStorage`.
- In-app rationale string: `lib/features/auto_upload/auto_upload_settings_screen.dart:765-767`
  — *"All files access — to delete recordings after successful upload."*

**Affects:** Play Store approval. This is the single biggest release blocker for the
Play track. (It does **not** block the direct-download / sideload APK or the Windows
builds.)

**Recommended action — pick one:**
1. **Scope down for Play:** replace All-files-access with `READ_MEDIA_AUDIO` +
   Storage Access Framework / `MediaStore`, requesting per-file delete consent via
   `MediaStore.createDeleteRequest`, and drop `MANAGE_EXTERNAL_STORAGE` from the AAB.
2. **Split builds:** keep `MANAGE_EXTERNAL_STORAGE` only in the direct-download
   APK / sideload variant (via a flavor or manifest placeholder) and strip it from
   the Play AAB.
3. **Declare and defend:** submit the Play Console permissions declaration with the
   delete-after-upload justification and accept the review risk.

Surface this prominently in `docs/play-store/` and the README before submitting to
Play.

---

## (d) iOS unverified — no Mac in CI — MEDIUM

**What:** An iOS project exists (`ios/Runner.xcodeproj`, `ios/Runner.xcworkspace`),
so the app can in principle build for iOS, but there is no macOS runner in CI, so
iOS is **never built, signed, or tested** by the pipeline. The release workflow
(`release.yml`) intentionally omits iOS.

**Evidence:**
- iOS platform dir present: `ios/` (`Runner.xcodeproj`, `Runner.xcworkspace`,
  `Runner`, `RunnerTests`).
- No macOS job anywhere: `ci.yml` runs a single `ubuntu-latest` job (analyze +
  test); `release.yml` builds on `ubuntu-latest` (Android) and `windows-latest`
  (Windows) only and does not build iOS (intentional — no Mac in CI).
- `README` "Known limitations" already notes iOS is untested in CI.

**Affects:** Release availability and quality for iOS. iOS artifacts are not
produced or smoke-tested anywhere automated; any iOS regression ships unverified.

**Recommended action:** Treat iOS as **not released** for now. State clearly in the
README / store materials that iOS is unverified and built ad-hoc on a developer Mac
(not from CI). If iOS becomes a supported channel later, add a `macos-latest` CI job
with code signing.

---

## (e) Linux not a target — LOW

**What:** Desktop support is Windows-only. There is **no `linux/` platform
directory**, so `flutter build linux` is not wired and Linux is out of scope.

**Evidence:**
- No `linux/` directory among the platform dirs (only `android/`, `ios/`, `windows/`).
- Note: `pubspec.yaml` uses `record: ^6.2.0` and has **no** `dependency_overrides`
  section. The `record_linux` pin called out in `AGENTS.md` pitfall #2 and the README
  "Known limitations" reflects an earlier dep graph; even when present it was only a
  transitive-dependency pin, **not** evidence of a Linux build target.

**Affects:** Scope clarity only. No build or store implications.

**Recommended action:** None required. Document "Windows is the only supported
desktop platform" so the lingering `record_linux` mentions in `AGENTS.md` / README
are not mistaken for Linux support.

---

## (f) Android release relies on debug-signing fallback — MEDIUM

**What:** The release build type loads `android/key.properties` when present and
otherwise **falls back to the debug signing config**. This fallback is intentional
and correct for local dev (so `flutter run --release` / local release builds work
without secrets), but it means a release build produced **without** the keystore is
silently signed with the debug key.

**Evidence:**
- `android/app/build.gradle.kts` — release `signingConfig` uses the `release` config
  only when `key.properties` exists, else `signingConfigs.getByName("debug")`.
- Secrets that must be present in CI for real signing:
  `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`,
  `ANDROID_KEY_PASSWORD` (decoded to `android/app/upload-keystore.jks`, written into
  `android/key.properties`).
- Keystore files are git-ignored: `.gitignore:56-59`
  (`android/key.properties`, `android/app/upload-keystore.jks`, `*.jks`, `*.keystore`).

**Affects:** Release-build integrity and Play upload. A debug-signed AAB/APK is
rejected by Play and cannot be installed as an upgrade over a release-signed build.
The risk is operational: if the CI secrets are missing/misconfigured, the pipeline
will still produce an artifact (debug-signed) rather than failing loudly.

**Recommended action:** Keep the fallback (it is the locked decision and is correct
for local dev), but in the release workflow add an explicit guard that **fails the
job** if `ANDROID_KEYSTORE_BASE64` is unset before building the AAB, so a publish
run can never emit a silently debug-signed artifact. Back up the keystore and record
its passwords securely (loss of the upload key blocks future Play updates).

**Status:** Guard implemented — `.github/workflows/release.yml`, step
"Verify Android signing secrets are present" (runs before "Decode release
keystore" and before any Android build; fails the job if any of the four
signing secrets is empty/unset). Keystore backup remains a manual task.

---

## (g) Windows build is unsigned (SmartScreen) — MEDIUM

**What:** The Windows installer (`Speakr-Setup-<version>.exe`) and portable zip
(`Speakr-<version>-windows-x64.zip`) are **not code-signed**. Windows SmartScreen
will show an "unrecognized app / unknown publisher" warning on first run, and some
browsers/AV may quarantine the download.

**Evidence:**
- Locked decision: Windows app is unsigned; do not attempt code signing.
- Installer config: `windows/installer/Speakr.iss` (Inno Setup, no signing tooling).
- Binary name `speakr_app.exe` (`windows/CMakeLists.txt:7`); the `.exe` FileVersion
  is driven from `--build-name`/`--build-number` via
  `windows/runner/CMakeLists.txt` → `windows/runner/Runner.rc` (no signing in that
  chain).

**Affects:** Install UX and download trust on Windows. Not a security defect per se
(the binary is just unsigned), but it adds friction and reduces user trust.

**Recommended action:** Document the SmartScreen warning and the click-through
("More info → Run anyway") in the README and on the GitHub Release page, and publish
the artifact's SHA-256 so users can verify the download. Do **not** attempt signing
(no certificate is in scope). Revisit later if an EV/OV code-signing certificate
becomes available.

---

## Cross-cutting notes (not blockers)

- **No telemetry / third-party backend** is a stated property; item (a) is the one
  outbound call on first launch (Google Fonts CDN) that contradicts it — bundling
  the TTFs also closes that gap.
- **Sensitive Android permissions beyond (c)** still need Play Console declarations
  even if not outright blockers: `READ_PHONE_STATE` (call-end trigger via
  `PhoneStateReceiver`), `FOREGROUND_SERVICE_MEDIA_PROJECTION` (capturing other apps'
  audio draws extra scrutiny), and `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`. See the
  permissions inventory in `android/app/src/main/AndroidManifest.xml` and the
  store-prep notes under `docs/play-store/`.
