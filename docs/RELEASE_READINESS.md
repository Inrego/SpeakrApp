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
| a | ~~Google Fonts fetched at runtime~~ | ~~**HIGH**~~ — **RESOLVED 2026-09-22** | First-launch UX (needs network) |
| b | `android:usesCleartextTraffic="true"` | MEDIUM | Security posture / Play review note |
| c | `MANAGE_EXTERNAL_STORAGE` (All files access) | **HIGH (Play)** — decision recorded 2026-09-22: declare and defend | Play approval |
| d | iOS unverified — no Mac in CI | MEDIUM | iOS release availability |
| e | Linux not a target | LOW | Scope clarity |
| f | Android debug-signing fallback | MEDIUM | Release-build integrity / Play upload |
| g | Windows build unsigned | MEDIUM | Install UX (SmartScreen) |

---

## (a) Google Fonts fetched at runtime — RESOLVED (2026-09-22)

**Was:** Runtime font fetching was explicitly enabled. The three brand typefaces
(Inter Tight, Source Serif 4, JetBrains Mono) were loaded via the `google_fonts`
package and were not bundled as assets, so a cold first launch needed network
access or the UI silently fell back to system fonts — and the outbound CDN call
contradicted the "no third-party backend" positioning in the store copy.

**What shipped:** 11 static TTFs under [`assets/fonts/`](../assets/fonts/),
registered per weight and style under `flutter: fonts:` in `pubspec.yaml`:

| Family | Weights | Italic |
|---|---|---|
| Source Serif 4 | 300, 400, 500, 600 | 400 |
| Inter Tight | 400, 500, 600 | 400 |
| JetBrains Mono | 400, 500 | — |

2,392,924 bytes uncompressed. That is exactly the set of faces reachable from
`SpeakrText.serif` / `.sans` / `.mono` across `lib/`; nothing wider is shipped,
because every unused face is dead weight in the AAB.

These are **static instances, not variable fonts**. Flutter picks a declared face
for a given `fontWeight`; it does not interpolate a variable font's `wght` axis
unless you pass `fontVariations` explicitly, so static per-weight files are the
only way to get the intended weights to render. Upstream `google/fonts` now
publishes all three families as variable TTFs only, so the bundled files are the
exact static instances `google_fonts` downloaded at runtime, fetched by sha256
from the `google_fonts` 8.1.0 manifest and verified against that manifest's
recorded hash and byte length — rendering is byte-identical to what shipped
before.

`lib/theme/typography.dart` now references the families by name
(`kSerifFamily` / `kSansFamily` / `kMonoFamily`). `SpeakrText`'s public surface is
unchanged, so no call site needed editing.

**`google_fonts` was removed from `pubspec.yaml` entirely**, rather than just
setting `allowRuntimeFetching = false`. Nothing referenced it once
`summary_tab.dart`'s one direct call was rewired, and removing the dependency is
strictly stronger than disabling the flag: there is no CDN code path left in the
binary at all, and the dep tree stays one package smaller (AGENTS.md pitfalls 1
and 2). Each family's `OFL.txt` is vendored alongside the fonts, as the OFL
requires.

**How it was verified:** built a debug APK and confirmed `FontManifest.json` lists
all three families with the expected per-weight assets, then ran it on the
`Medium_Phone_API_36.1` AVD against the mock server. The new onboarding capture is
pixel-identical to the committed `docs/screenshots/mobile-onboarding.png` below
the status bar (0 differing pixels of 2,473,200) — which exercises the serif
regular *and* true italic, Inter Tight, and the JetBrains Mono eyebrow. On the
library screen, 0 differing pixels are text; all 10,917 are the folder colour
swatches, which are mock-server state rather than type. `flutter analyze` is
clean and all 76 tests pass.

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

## (c) `MANAGE_EXTERNAL_STORAGE` / All files access — HIGH (Play track)

**Status: DECIDED — 2026-09-22.** Option 3, **declare and defend**, is the chosen
route. `MANAGE_EXTERNAL_STORAGE` stays declared in the manifest and requested at
runtime; nothing about the app's behaviour changes. The Play Console
permissions-declaration copy is written and ready to paste:
[`play-store/permissions-declaration.md`](play-store/permissions-declaration.md).

**What:** The app declares and requests All-files-access. Google Play classifies
`MANAGE_EXTERNAL_STORAGE` as a restricted permission limited to a narrow set of app
categories (file managers, backup, antivirus, etc.), so shipping it requires the
Play Console restricted-permission declaration plus a permission-use review.

**Why the permission is needed:** the auto-upload feature watches folders the user
picks, uploads recordings written there by *other* apps (call recorders, voice
recorders) to the user's own server, and then deletes the local copy so the device
does not fill up. MediaStore/SAF cannot delete another app's file without a
per-file system consent prompt, which cannot be answered by an unattended
background upload triggered by a periodic job or by the end of a call.

**Evidence:**
- Declared: `android/app/src/main/AndroidManifest.xml:13` —
  `<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"/>`.
- Requested at runtime: `lib/features/auto_upload/auto_upload_settings_screen.dart:691`
  — `Permission.manageExternalStorage`.
- In-app rationale string: `lib/features/auto_upload/auto_upload_settings_screen.dart:765-767`
  — *"All files access — to delete recordings after successful upload."*
- Delete-after-upload: `lib/features/auto_upload/auto_upload_worker.dart:396-415`
  (`deleteLocalAutoUploadFile`), called at `:482`.

**Affects:** Play Store approval only. The direct-download / sideload APK and the
Windows builds are unaffected.

**Accepted risk (stated, not mitigated):** a transcription/upload client is not on
Google's approved category list for All-files-access, so the declaration may be
**denied**, which would block the Play track until the app is changed. The
maintainer accepts that risk in exchange for keeping one build and one code path.

**Documented fallbacks if the declaration is denied:**
1. **Scope down for Play:** replace All-files-access with `READ_MEDIA_AUDIO` +
   Storage Access Framework / `MediaStore`, requesting per-file delete consent via
   `MediaStore.createDeleteRequest`, and drop `MANAGE_EXTERNAL_STORAGE` from the AAB.
   Costs the unattended delete-after-upload flow.
2. **Split builds:** keep `MANAGE_EXTERNAL_STORAGE` only in the direct-download
   APK / sideload variant (via a flavor or manifest placeholder) and strip it from
   the Play AAB. Costs a second build configuration and a feature gap on Play.

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

- **No telemetry / third-party backend** is a stated property, and as of
  2026-09-22 it holds: item (a) was the one outbound call on first launch (Google
  Fonts CDN), and bundling the TTFs plus dropping the `google_fonts` dependency
  closed that gap.
- **Sensitive Android permissions beyond (c)** still need Play Console declarations
  even if not outright blockers: `READ_PHONE_STATE` (call-end trigger via
  `PhoneStateReceiver`), `FOREGROUND_SERVICE_MEDIA_PROJECTION` (capturing other apps'
  audio draws extra scrutiny), and `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`. The
  ready-to-paste Console copy for every one of these is in
  [`play-store/permissions-declaration.md`](play-store/permissions-declaration.md);
  the raw inventory is `android/app/src/main/AndroidManifest.xml`.
