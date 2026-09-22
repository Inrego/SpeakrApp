# Play Console Submission Runbook — `com.inrego.speakr_app`

One sitting, top to bottom. Every answer you need is in this file; you should not
have to open `checklist.md`, `data-safety.md`, `permissions-declaration.md` or
`listing.md` while you work. Those stay as the reasoning behind the answers —
this is the answers.

**How to read each item**

- **Where:** Console section → subsection → field.
- **Enter / Select:** a fenced block is verbatim paste-able text; a bolded word
  is the option to select.
- **Why:** one line, so you can defend the answer if a reviewer asks.

**Conventions**

- ⚠️ **NAMING UNVERIFIED** — I am confident the form exists and what it asks,
  but not of Google's exact current wording/path. Read the screen, don't
  pattern-match my label.
- 🔒 **DECISION** — you must choose; I give a recommendation and the trade-off.
- ⏳ **AFTER AAB** — the form does not exist (or is not enforced) until a bundle
  has been uploaded. Skip on the first pass; see §6.

**Verified against the repo at `main` = `11c9e82`** (PRs #3, #4, #5 merged).
`MANAGE_EXTERNAL_STORAGE` is **not** in `android/app/src/main/AndroidManifest.xml`.
`https://inrego.github.io/SpeakrApp/privacy-policy.html` returns **HTTP 200**.

---

## §0 — Before you open the Console

| Check | Why |
| --- | --- |
| The AAB you upload is built from a commit **at or after #4** (SAF migration). | An older bundle still carries `MANAGE_EXTERNAL_STORAGE`; the Console detects it in the bundle and demands an All-files-access declaration that this runbook deliberately does not provide. `main` is clean today. |
| Re-read `android/app/src/main/AndroidManifest.xml` immediately before filling §4 (permissions). | A separate permission-audit is in flight and may change the declared set (notably `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`). **The manifest is the source of truth for which declaration forms you will be asked to fill — not this runbook, and not `permissions-declaration.md`.** |
| Keystore backed up, passwords recorded. | Losing the upload key blocks every future update. The four CI secrets are `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`. |
| Confirm the AAB is **not** debug-signed. | `android/app/build.gradle.kts` silently falls back to the debug signing config when `android/key.properties` is absent. CI has a guard step that fails the job if a signing secret is missing; a local build has no such guard. |

### Recommended order

The Console lets you do these in any order, but this order minimises rework:

1. **Upload an AAB to Internal testing first** (§5.2), *without* rolling it out.
   This makes the Console read your manifest, which unlocks the permission and
   foreground-service declaration forms (⏳ items) and the pre-launch report.
2. Then work §1 → §4 below.
3. Then come back and finish the release (§5).

If you prefer to fill the paperwork first, that works too — just expect the ⏳
items to be missing until step 1 happens.

---

## §1 — Store listing

**Where:** Grow users → Store presence → **Main store listing**

### 1.1 App name (max 30 chars)

```
Speakr
```

**Why:** matches `android:label="Speakr"` and the desktop branding. 6 chars.
If Play rejects it as colliding with an existing app, use this instead (26 chars):

```
Speakr — Transcribe Client
```

### 1.2 Short description (max 80 chars)

```
Record & transcribe meetings on your own self-hosted Speakr server.
```

**Why:** 67 chars; leads with the self-hosted requirement so the listing sets
expectations before install.

### 1.3 Full description (max 4000 chars)

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
  a metadata tab — all in one detail view.
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
• Audio/storage access to read files you want to upload, and — for auto-upload
  only — access to the folders you pick.

Speakr is cross-platform: Android, iOS, and Windows desktop. (iOS builds are
not produced in this project's CI.)
```

**Why:** ~2,810 chars. The storage bullet already describes the **SAF** model
("only the folders you pick") — it is post-migration and correct as written. Do
not reintroduce any wording about broad or all-files storage access.

### 1.4 Graphics

| Field | File in this repo | Spec check |
| --- | --- | --- |
| App icon | `docs/play-store/assets/icon-512.png` | 512×512 RGBA, 8.4 KB |
| Feature graphic | `docs/play-store/assets/feature-graphic-1024x500.png` | 1024×500, RGB, **no alpha** (verified) |
| Phone screenshots (≥2, ≤8) | `docs/screenshots/mobile-onboarding.png`, `mobile-library.png`, `mobile-detail.png`, `mobile-live.png`, `mobile-settings.png` | all 1080×2400 |

Do **not** upload `docs/screenshots/mobile.png` — it is a duplicate of the
detail screen kept for the README hero.

**Watch at upload:** 1080×2400 is 20:9 (2.22:1), slightly past a strict 2:1
reading of Play's aspect spec. If the Console rejects them, pad or re-capture at
1080×1920. Regenerate icon + feature graphic with
`dart run tools/build_store_graphics.dart`.

**Why the screenshots are safe to publish:** they were captured against the
local mock server, so no real recordings appear in the listing.

### 1.5 Tablet screenshots

**Select:** skip. **Why:** optional; the app is not tablet-optimised and
claiming otherwise invites a layout complaint.

### 1.6 App category and contact details

**Where:** Grow users → Store presence → **Store settings**
⚠️ **NAMING UNVERIFIED** — category and contact details have moved between
"Main store listing" and "Store settings" across Console revisions.

| Field | Value |
| --- | --- |
| App or game | **App** |
| Category | **Productivity** (alternative: Business) |
| Tags | Pick from Play's controlled list — "Productivity", "Tools". No free-form tags. |
| Email (public, required) | `rss@khd.dk` |
| Website (optional) | `https://github.com/Inrego/SpeakrApp` |
| Phone (optional) | leave blank |

---

## §2 — App access (do this one carefully)

**Where:** Policy and programs → **App content** → **App access**

**Select:** **All or some functionality is restricted**

**Why:** the app is a client for a server the user supplies. On first launch it
shows a three-step onboarding ending in a **Server URL** + **API Token** form.
With no server, the reviewer gets a connection error and sees nothing else.
A blank or "no restrictions" answer here is one of the most common rejection
causes for apps of this shape.

You then add one or more **instructions** entries. Each entry has a name, a
username field, a password field, and a free-text "any other instructions"
field ⚠️ **NAMING UNVERIFIED** — treat the username/password fields as
optional-but-present, and put everything that is not a literal credential in
the free-text field. I do **not** know the current character limit on that
field; if the text below is truncated, cut from the bottom (the "What you can
verify without connecting" paragraph) first.

Because Speakr has no username/password, put the **Server URL** in the username
field and the **API Token** in the password field, and say so in the text.

### 2.1 🔒 DECISION — which variant to submit

You have said you do not want to host the mock server publicly. Both variants
are written out. Read §2.4 before choosing: **Variant B is materially likely to
fail review**, and my recommendation is Variant A.

### 2.2 Variant A — hosted mock server (RECOMMENDED)

Entry name:

```
Speakr demo server
```

Username field:

```
https://<your-public-host>
```

Password field:

```
speakr-demo-token
```

Any other instructions:

```
Speakr is a client for a Speakr transcription server that the user hosts
themselves. The app has no accounts and no developer-operated backend; it needs
a server URL and an API token, which act as the credentials.

To get in:
1. Launch the app. Tap "Next" twice through the two intro screens.
2. On the third screen ("Let's connect to your Speakr"), enter:
   Server URL: https://<your-public-host>
   API Token:  speakr-demo-token
3. Tap "Connect". The library screen opens with six demo recordings.

The server above is a demo instance seeded with fictional data, provided for
this review. All app functionality is reachable from the library screen:
tap a recording for its summary, transcript and speaker review; the "+" action
opens the live recorder; Settings holds the connection and auto-upload options.
```

**What hosting takes** (so you can price the decision):

```bash
dart compile exe tools/mock-server/bin/speakr_mock_server.dart -o speakr-mock-server
./speakr-mock-server --port 8420
```

Single static binary, no dependencies beyond the Dart SDK at compile time, no
state on disk, in-memory only, restart resets it. Put it behind any
TLS-terminating proxy — Caddy, nginx, or a Cloudflare Tunnel (a tunnel needs no
public IP and no certificate work). Realistically: 30–60 minutes once, plus
keeping a small VM or tunnel alive for the review window and for every future
update review. There is nothing secret in it; the data is invented.

### 2.3 Variant B — no hosted server, reviewer runs it themselves

Entry name:

```
Speakr demo server (reviewer-run)
```

Username field:

```
http://10.0.2.2:8420
```

Password field:

```
speakr-demo-token
```

Any other instructions:

```
Speakr is a client for a Speakr transcription server that the user hosts
themselves. There are no accounts; a server URL and an API token are the
credentials. A demo server is included in the app's public source repository
and can be run locally on the review machine.

Setup (once, ~5 minutes, on the machine running the emulator):
1. Install the Dart SDK 3.11 or later (https://dart.dev/get-dart).
2. git clone https://github.com/Inrego/SpeakrApp
3. cd SpeakrApp && dart run tools/mock-server/bin/speakr_mock_server.dart
   It listens on 0.0.0.0:8420 and prints nothing further. Leave it running.

In the app:
4. Launch the app. Tap "Next" twice through the two intro screens.
5. On the third screen ("Let's connect to your Speakr"), enter:
   Server URL: http://10.0.2.2:8420   (Android emulator reaches the host at
   10.0.2.2. On a physical device on the same network use
   http://<host-LAN-IP>:8420 instead.)
   API Token:  speakr-demo-token
6. Tap "Connect". The library screen opens with six demo recordings.

Without a server the app cannot proceed past that connection screen; this is
the app's entire purpose, not a paywall or a hidden feature.
```

⚠️ Verify the clone URL before pasting. The repo must be **public** at review
time or step 2 fails outright.

### 2.4 Honest assessment of Variant B

Plainly: **I expect Variant B to fail review, and I would not bet on it.**

- It asks a reviewer to install a language SDK, clone a git repo, and run a
  server process on their own machine. Play review is a high-throughput process;
  instructions that require developer tooling on the reviewer's host are outside
  what the App access field is designed for.
- It assumes the reviewer uses an emulator on a machine they control, and that
  `10.0.2.2` applies. If review runs on a physical device farm, `10.0.2.2` is
  wrong and the LAN-IP fallback is unreachable from their network.
- There is **no prebuilt mock-server binary published anywhere today** — I
  checked `.github/workflows/release.yml`, which builds only the AAB and the
  universal APK. So "download and run" is not currently an option; it is
  "install Dart and build it".
- The likely outcome is a rejection citing inability to access app
  functionality. That costs a review cycle (days), and repeated access
  rejections are worse than a single delay.

**A middle option, if the objection to Variant A is running infrastructure
indefinitely:** stand the mock server up behind a Cloudflare Tunnel only for the
review window, submit, and take it down after approval — then bring it back for
each update review. This keeps the reviewer's path to one screen of typing while
your exposure is a few days at a time of an invented-data endpoint. It is what
`tools/mock-server/README.md` was built for (its stated job #2 is exactly this).

If you still want Variant B, submit it — but plan for the rejection and have
Variant A ready to swap in.

---

## §3 — App content forms

**Where:** Policy and programs → **App content**. Work the list top to bottom;
the Console shows each as Not started / In progress / Completed.

### 3.1 Privacy policy

**Where:** App content → **Privacy policy** → *Privacy policy URL*

**Enter:**

```
https://inrego.github.io/SpeakrApp/privacy-policy.html
```

**Why:** required because the app requests microphone, phone state, and captures
other apps' audio via media projection. **Verified live — returns HTTP 200.**
Source of truth is `docs/play-store/privacy-policy.md`; the published copy is
`site/privacy-policy.html` and CI checks the two match.

### 3.2 Ads

**Where:** App content → **Ads** → *Does your app contain ads?*

**Select:** **No, my app does not contain ads**

**Why:** no ad SDK in `pubspec.yaml` (no AdMob, Facebook, Unity Ads, etc.).

### 3.3 Content rating (IARC questionnaire)

**Where:** App content → **Content rating** → *Start questionnaire*

| Field | Answer |
| --- | --- |
| Email address | `rss@khd.dk` |
| Category | **Utility, Productivity, Communication, or Other** ⚠️ NAMING UNVERIFIED — IARC's category list wording shifts; pick the utility/productivity bucket, not Social Networking. |

Then the questionnaire itself. Expected answers — **No** to all of:

- Violence (realistic, fantasy, sexual, or otherwise)
- Sexuality / nudity
- Profanity or crude humour
- Controlled substances (drugs, alcohol, tobacco)
- Gambling, simulated gambling, or real-money gaming
- Horror / fear themes
- In-app purchases

The questions that need thought:

| Question (paraphrased) | Answer | Why |
| --- | --- | --- |
| Does the app let users interact or exchange content with other users? | **No** | Recordings go to the user's own private server. There is no in-app feed, no other users, no sharing surface between users of the app. |
| Does the app share the user's current physical location with other users? | **No** | No location permission is declared and no location is collected. |
| Does the app allow users to purchase digital goods? | **No** | No IAP, no billing library. |
| Does the app contain user-generated content that is publicly accessible? | **No** | Same as above — the audio never reaches a public or shared surface. |
| Does the app provide an unfiltered internet browser / search? | **No** | No WebView browser surface. |

**Expected outcome:** **Everyone** (IARC 3+ / PEGI 3 / ESRB Everyone).

**Why the UGC answers are No:** Speakr records and uploads the user's own audio
to a server that only the user can reach. That is user-generated content in the
plain sense, but not in IARC's sense — IARC's UGC questions are about content
becoming visible to *other users of the app*, which never happens here.

### 3.4 Target audience and content

**Where:** App content → **Target audience and content**

| Field | Select | Why |
| --- | --- | --- |
| Target age groups | **18 and over** only | Sensitive permissions plus a self-hosting requirement make this unambiguously an adult tool. Selecting any under-18 band pulls you into the Families policy and Designed for Families review. |
| Appeal to children (store listing, content, visuals) | **No** | Neutral typographic design, no characters, no play elements. |
| ⏳ Google Play SDK Index / ads-and-children follow-ups | answer as prompted | Only appears for some age selections. |

### 3.5 News apps

**Where:** App content → **News apps** → *Is your app a news app?*

**Select:** **No** — **Why:** no editorial content; the app displays only the
user's own recordings and the server's transcripts of them.

### 3.6 COVID-19 contact tracing and status apps

**Where:** App content → **COVID-19 contact tracing and status apps**

**Select:** **No** (my app is not a publicly available COVID-19 contact tracing
or status app) — **Why:** no health-authority affiliation, no exposure
notification, no health status.

### 3.7 Government apps

**Where:** App content → **Government apps** → *Is your app a government app?*

**Select:** **No** — **Why:** published by an individual developer; not on
behalf of, nor in partnership with, any government entity.

### 3.8 Financial features

**Where:** App content → **Financial features**

**Select:** **My app doesn't provide any financial features**

**Why:** no payments, no lending, no crypto, no investment, no insurance, no
banking. No billing library in the dependency tree.

### 3.9 Health apps

**Where:** App content → **Health apps** ⚠️ NAMING UNVERIFIED — this has
appeared as "Health apps" and as a health declaration inside the advanced
declarations list.

**Select:** **No / my app does not provide health features**

**Why:** the app records and transcribes audio. It makes no health claim, does
no health research, provides no medical function, and integrates no health data
API (no Health Connect, no Google Fit).

### 3.10 Data deletion / account deletion

**Where:** App content → **Data deletion** ⚠️ NAMING UNVERIFIED — also surfaced
inside the Data safety flow.

| Field | Answer | Why |
| --- | --- | --- |
| Does your app allow users to create an account? | **No** | There is no developer-side account. The API token is a credential for *the user's own* server, created on that server, never seen by the developer. |

If the form nevertheless asks for a deletion instructions URL, use the privacy
policy URL from §3.1 — it documents that deletion happens on the user's own
server or by uninstalling.

---

## §4 — Data safety (the long one)

**Where:** App content → **Data safety**

Google's definition of "collect" is **transmitted off the device** — regardless
of who receives it. Speakr transmits audio and metadata to the user's own
server, so it *collects*, even though you never receive anything. Answer
honestly and use the free text to explain the self-hosted model. Under-declaring
here is the failure mode that gets apps pulled later.

### 4.1 Overview / Data collection and security

| Question | Answer | Why |
| --- | --- | --- |
| Does your app collect or share any of the required user data types? | **Yes** | Audio and metadata are transmitted off the device to the user's server. |
| Is all of the user data collected by your app encrypted in transit? | 🔒 **DECISION — recommended: No** | `android:usesCleartextTraffic="true"` (`AndroidManifest.xml`) permits plain HTTP, which many self-hosted LAN servers use. The checkbox is all-or-nothing: if HTTP is possible, you cannot truthfully claim all data is encrypted. Answering **Yes** is a false statement in a legally binding form. The cost of **No** is a "Data isn't encrypted in transit" line on your store listing — which is honest for a LAN-first self-hosted client, and which the free text in §4.4 explains. *The only way to flip this to Yes is to enforce HTTPS in a future build.* |
| Do you provide a way for users to request that their data is deleted? | **Yes** | The developer holds no data; the user deletes on their own server, or by uninstalling. Documented in the privacy policy. |

### 4.2 Data types — which to select

In the data type grid, select **only** these two. Everything else is **not**
selected.

1. **Audio files** → subtypes **Voice or sound recordings** *and* **Other audio
   files**
2. **App activity** → subtype **Other user-generated content**

**Why "Other audio files" as well as "Voice or sound recordings":** auto-upload
picks up audio files that *other apps* wrote (call recorders, voice recorders)
from folders the user chose, and uploads them. Those are not the app's own
microphone recordings. Ticking both covers the auto-upload path.

### 4.3 Per-type answers

#### Audio files → Voice or sound recordings

| Question | Answer |
| --- | --- |
| Is this data collected, shared, or both? | **Collected** ✅ · **Shared** ❌ |
| Is this data processed ephemerally? | **No** |
| Is this data required or optional? | **Required** (users can't turn off this collection) |
| Why is this data collected? | **App functionality** only |

**Why not Shared:** Play defines "shared" as transfer to a *third party*. The
user's own server, at a URL the user typed, is the user's designated
destination, not a third party. Nothing goes to the developer and there is no
third-party SDK.

**Why not ephemeral:** the recording is stored on the user's server for
transcription; it is not discarded after in-memory processing.

**What this audio can contain** (say it in the free text, §4.4, not in a field):
the microphone; **other apps' playback audio** captured via `MediaProjection`
when the user turns the system-audio source on for a session — which can include
other participants of a call or meeting; and **audio files written by other
apps** that auto-upload collects from user-chosen folders.

#### Audio files → Other audio files

| Question | Answer |
| --- | --- |
| Collected / Shared | **Collected** ✅ · **Shared** ❌ |
| Processed ephemerally | **No** |
| Required or optional | **Optional** (users can choose whether this data is collected) |
| Why collected | **App functionality** |

**Why optional:** auto-upload is off until the user enables it and picks a
folder. Microphone recording is the required path; this one is opt-in.

#### App activity → Other user-generated content

Covers tags, notes, speaker names, meeting date, language and speaker-count
settings, and — for auto-uploaded files — the **file name** and
**last-modified time** (sent as the meeting date).

| Question | Answer |
| --- | --- |
| Collected / Shared | **Collected** ✅ · **Shared** ❌ |
| Processed ephemerally | **No** |
| Required or optional | **Optional** |
| Why collected | **App functionality** |

### 4.4 Everything you answer NO to, and why

Do **not** select any of these. If a reviewer queries one, this is the answer:

| Data type | Why No |
| --- | --- |
| **Location** (approximate, precise) | No location permission declared; no location API used. |
| **Personal info** (name, email, user IDs, address, phone number, race/ethnicity, political or religious beliefs, sexual orientation, other) | None is requested or transmitted. See the API-token note below. |
| **Financial info** | No payments, no purchase history, no billing library. |
| **Health and fitness** | None. |
| **Messages** (emails, SMS/MMS, other in-app messages) | None read or sent. |
| **Photos and videos** | **Media projection captures audio only** — the app uses `AudioPlaybackCaptureConfiguration` and never creates a `VirtualDisplay` or reads screen pixels. The user sees Android's *screen-capture* consent dialog because that is the only consent surface Android offers for the API; no screen content is ever read. |
| **Files and docs** | The app reads audio files, which are declared under Audio files. It does not collect documents. |
| **Calendar** | No calendar permission; the events endpoint exists server-side but no screen consumes it. |
| **Contacts** | No contacts permission. |
| **App activity** → App interactions, In-app search history, **Installed apps**, Other actions | None transmitted. See the Windows note below on Installed apps. |
| **Web browsing history** | None. |
| **App info and performance** (crash logs, diagnostics, other performance data) | No crash-reporting or analytics SDK — no Firebase, Crashlytics, Sentry, Analytics, Amplitude, Mixpanel, Segment, Facebook. Verified against `pubspec.yaml`. |
| **Device or other IDs** | No advertising ID, no device identifier collected; no ad or analytics SDK to collect one. |

Three notes worth having ready:

- **API token and server URL are not "collected."** They live in OS secure
  storage (`flutter_secure_storage`, Android Keystore-backed) and are sent only
  to the user's own server as an auth header. They never reach the developer or
  any third party. Do not declare them as Personal info → User IDs.
- **`READ_PHONE_STATE` adds no data type.** The app reads only the call *state*
  (ringing/off-hook/idle) to time an upload scan. It never reads the phone
  number, subscriber identity, device identifiers, or the call log — no
  `READ_CALL_LOG` / `PROCESS_OUTGOING_CALLS` anywhere in the manifest — and it
  transmits nothing.
- **The Windows microphone monitor is out of scope for this form.** The Windows
  build polls the registry for which apps are using the mic and keeps a local
  list of up to ~30 recent app names. `createMicMonitor` is a no-op off Windows,
  so it is **not in the Android app at all**, it is never transmitted, and it
  does not change the **Installed apps** answer. It is disclosed in the privacy
  policy so the hosted policy and this form stay consistent.
- **Transcripts and summaries** are generated *by the user's server* and fetched
  back into the app. They are not data the app collects from the user. They are
  covered by the free text rather than as a separate declared type.

### 4.5 Security practices

| Question | Answer | Why |
| --- | --- | --- |
| Is data encrypted in transit? | **No** (per the §4.1 decision) | Cleartext HTTP is permitted for LAN self-hosted servers. |
| Do you provide a way for users to request data deletion? | **Yes** | On their own server or device; no developer-held data. |
| Have you committed to follow the Play Families Policy? | **No / N/A** | Not a children's app (§3.4). |
| Has your app been independently validated against a global security standard? | **No** | No review has been performed. |

### 4.6 Free text / additional context

Paste this wherever the form offers an explanation field, and again in the
release **review notes** (§5.3):

```
Speakr is a client for a Speakr transcription server that the user hosts
themselves. All audio recordings and associated metadata are transmitted only
to the server URL the user configures; the developer operates no backend and
never receives user data. Recordings can include the microphone and, when the
user turns it on for a session and accepts Android's consent dialog, audio
played by other apps (which may include other call participants); only audio is
captured, never screen content. Auto-upload sends audio files from folders the
user selected through Android's Storage Access Framework, and then deletes the
local file after the server confirms the upload; it also deletes files shorter
than a user-set minimum duration without uploading them. The app can only see
and delete files inside the folders the user picked, and the user can revoke a
folder at any time in Auto-upload settings. The server URL and API token are
stored locally in the device's encrypted OS secure storage and are sent only to
the user's own server for authentication. The app integrates no analytics,
advertising, or third-party tracking. Data deletion is performed by the user on
their own server or device. Cleartext HTTP is permitted app-wide because
self-hosted Speakr servers commonly run at a plain http:// address on a home or
office LAN with no TLS certificate.
```

---

## §5 — Permission and foreground-service declarations

⏳ **These forms are driven by what the Console detects in an uploaded bundle.**
Expect them to be absent or greyed out until an AAB is in a track (§6).

> **Before filling any of these, re-read `android/app/src/main/AndroidManifest.xml`.**
> A permission audit is in flight and the declared set may have changed since
> this runbook was written. The Console will ask about exactly what is in the
> bundle you uploaded — no more, no less. If the Console asks for a form that is
> not covered below, stop and check the manifest rather than improvising.

**Where:** App content → **Sensitive app permissions** and App content →
**Foreground service permissions** ⚠️ NAMING UNVERIFIED — these have been a
single "Permissions declaration form" and separate entries in different Console
revisions.

### 5.1 All files access — DO NOT FILL

**Do not fill in an All files access / `MANAGE_EXTERNAL_STORAGE` declaration,
and do not record a demo video.**

**Why:** the permission was removed in PR #4 and is **verified absent from
`AndroidManifest.xml` at `main`**. Auto-upload now uses the Storage Access
Framework: the user picks each folder with `ACTION_OPEN_DOCUMENT_TREE`, the app
takes a persistable URI permission on that tree, and thereafter lists, reads and
deletes documents inside it via `DocumentsContract` / `DocumentFile`. A
persisted tree grant allows unattended deletion from a background worker with no
per-file dialog — which is exactly the delete-after-upload flow — so the
restricted permission was never needed. The Console should not ask for this
form. **If it does, the AAB you uploaded predates #4 — rebuild, do not fill the
form.**

If a reviewer asks what the SAF grant covers: the app can enumerate, read and
delete only within the trees the user picked; it cannot see anything else on
external storage; and the user can revoke a grant by removing the folder in
Auto-upload settings (which calls `releasePersistableUriPermission`) or by
uninstalling.

### 5.2 Foreground service — Microphone

**Where:** App content → Foreground service permissions → **Microphone**

**Type:** `android.permission.FOREGROUND_SERVICE_MICROPHONE`; service
`.audio.AudioCaptureService`, declared
`android:foregroundServiceType="mediaProjection|microphone"`.

**Enter:**

```
Speakr records meetings and calls so they can be transcribed on the user's own
server. Recording is started explicitly by the user from the in-app recorder
screen, and a session can easily run for an hour. The microphone foreground
service keeps the capture alive while the user switches to another app, or
while the screen is off, and keeps a persistent notification on screen for the
whole session so it is always obvious that recording is in progress. Without
the foreground service the capture is killed as soon as the app leaves the
foreground and the user loses the meeting. There is no recording without an
explicit user action; the service is started when recording starts and stopped
when recording stops.
```

### 5.3 Foreground service — Media projection

**Where:** App content → Foreground service permissions → **Media projection**

**Type:** `android.permission.FOREGROUND_SERVICE_MEDIA_PROJECTION`; the **same**
service `.audio.AudioCaptureService` — microphone and mediaProjection are two
types on one service, not two services.

**Enter:**

```
This is used to capture device audio — the other side of a video meeting or
VoIP call, or any media the device is playing — alongside the microphone, so
the transcript contains both sides rather than only the person holding the
phone. Android exposes system audio capture only through MediaProjection
(AudioPlaybackCaptureConfiguration), so it is the only API that produces a
usable two-sided recording. The capture is limited to what Android makes
available to that API: streams tagged USAGE_MEDIA, USAGE_GAME, and
USAGE_UNKNOWN. Apps that opt out of playback capture, and ordinary telephony
audio, are excluded by the platform.

Capture is user-initiated per session and never persists. Each time the user
starts a system-audio recording, Android shows its own screen-capture consent
dialog, launched by the app via
MediaProjectionManager.createScreenCaptureIntent(); recording only proceeds if
the user approves that dialog, and the projection is released when the session
ends. No consent is cached or reused across sessions. The app captures audio
only — it never reads, stores, or transmits screen pixels. The captured audio
goes to one destination: the user's own self-hosted Speakr server, at a URL the
user entered. It is not sent to me, to any third-party service, or to any
analytics or advertising SDK. The app's public privacy policy discloses this
capture, including that other call participants may be recorded, under
"Recording other apps' audio".
```

**Expect extra scrutiny on this one.** It is the declaration most likely to draw
a follow-up question. The two facts that carry it: per-session system consent
dialog, and audio-only (no `VirtualDisplay`).

### 5.4 Foreground service — Data sync

**Where:** App content → Foreground service permissions → **Data sync**

**Type:** `android.permission.FOREGROUND_SERVICE_DATA_SYNC`.

**Enter:**

```
Auto-upload transfers audio files from folders the user selected to the user's
own Speakr server. The work is scheduled with Android's WorkManager — a
periodic job plus a one-shot job enqueued when a phone call ends — and a
recording can be a long file over a slow uplink, so WorkManager may need to run
the transfer as a data-sync foreground service to finish it without being
killed mid-upload. The notification tells the user an upload is in progress.
The only network destination is the server URL the user configured; nothing is
synced anywhere else.
```

**If the form asks which service uses this type:** name **WorkManager's
`androidx.work.impl.foreground.SystemForegroundService`**. The app declares no
`dataSync` service of its own — the only app-declared service is
`.audio.AudioCaptureService` (`mediaProjection|microphone`). WorkManager merges
its own service into the manifest and sets the type at runtime.

### 5.5 `READ_PHONE_STATE`

**Where:** App content → Sensitive app permissions (phone group) — and repeat in
the release review notes.

**Enter:**

```
A large part of Speakr's audience uses it with a call-recorder app. Those apps
finish writing a recording when the call ends, so the app listens for the phone
state going from off-hook to idle and, about 40 seconds later, enqueues a
single background scan of the user's watched folders. That is the entire use: a
timing signal that says "a new recording may have just landed on disk, go
look". Polling on a timer instead would either miss recordings for up to
fifteen minutes or waste battery scanning constantly.

The app reads only the call state broadcast. It does not read the phone number,
the subscriber identity, the device identifiers, or the call log — no call-log
permissions (READ_CALL_LOG, PROCESS_OUTGOING_CALLS) are declared anywhere in
the manifest — and it does not record calls itself.
```

**Evidence if asked:** `android/app/src/main/kotlin/com/inrego/speakr_app/PhoneStateReceiver.kt`
(off-hook → idle enqueues a WorkManager one-shot) and the receiver registration
in `AndroidManifest.xml`.

### 5.6 `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` — 🔒 CHECK THE MANIFEST FIRST

**Do not paste a justification for this until you have confirmed what the
shipping manifest declares.** As of `main` the permission is still declared but
nothing in `lib/` or `android/` requests it — there is no
`Permission.ignoreBatteryOptimizations` call and no
`ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` intent. The permission-audit work
in flight may remove it.

- If the audit **removes it**: nothing to declare. Skip this item.
- If it **stays and a user-tapped request is wired**: justification text is in
  `permissions-declaration.md` §6 — but read that section's warning first.
- If it **stays unwired**: you would be justifying a permission the app never
  uses. Fix the code or drop the permission rather than writing around it.

### 5.7 Cleartext traffic — review note, not a form

There is no Console form for this; it goes in the release **review notes**
(§6.3) and is worth repeating in the Data safety context field.

```
Speakr talks to a server the user hosts themselves and enters the URL for at
first run. In practice a large share of those servers run on a home or office
LAN at a plain http:// address with no TLS certificate — a self-signed
certificate would be worse for the user than plain HTTP on their own network.
If the app refused cleartext, those users could not connect at all. Cleartext
is therefore enabled app-wide by design, not by oversight. The app ships no
hard-coded server and contacts no backend of mine; the only host it talks to is
the one the user typed in. A future release may narrow this to a
network_security_config.xml that permits cleartext only for the
user-configured host.
```

The **pre-launch report** will flag cleartext. That is expected and is not a
blocker.

---

## §6 — Release setup

### 6.1 Play App Signing

**Where:** Release → Setup → **App integrity** → *App signing* ⚠️ NAMING
UNVERIFIED — enrolment is also offered inline when you create your first release.

**Select:** **Let Google create and manage my app signing key** (the default for
a new app), then upload your AAB signed with the **upload key**.

**Why:** you sign with `android/app/upload-keystore.jks` (CI secret
`ANDROID_KEYSTORE_BASE64`); Google re-signs with the app signing key it holds.
Enrolment is effectively irreversible — but it is also the only way to recover
from losing the upload key later, which is the risk worth insuring against.

### 6.2 Upload the AAB

**Where:** Release → Testing → **Internal testing** → *Create new release*

Do this **first**, before the paperwork, and **do not roll out**. It makes the
Console read the manifest, which is what unlocks the ⏳ items.

| Item | Value |
| --- | --- |
| Bundle | the `.aab` from the release workflow (`dist/Speakr-<version>.aab`) |
| `versionCode` | GitHub Actions run number — must be strictly higher than any previous upload |
| Universal APK | **do not upload** — it is for direct GitHub download only |

Watch the Console's permissions summary on upload: `MANAGE_EXTERNAL_STORAGE`
must **not** appear. If it does, the bundle predates PR #4 — rebuild.

### 6.3 Release notes and review notes

Release notes (user-facing) are your call. The **review notes** field (internal,
for the reviewer) should carry: the §5.7 cleartext note, the §4.6 free text, and
a one-line pointer to the App access instructions.

### 6.4 Countries and regions

**Where:** Release → Production (or the chosen track) → **Countries/regions**

**Select:** all countries, unless you have a reason to restrict.
**Why:** English-only strings (no i18n) but no legal or regional constraint.

### 6.5 Pricing

**Where:** Monetise → **Products** / app pricing ⚠️ NAMING UNVERIFIED

**Select:** **Free**

**Why:** no in-app purchases and no billing library in the dependency tree.
**Free → paid is not reversible on Play.** Free is the right call and the
reversible one.

---

## §7 — Items that must wait for an AAB upload

Skip these on a first pass; they do not exist or are not enforceable until a
bundle is in a track.

| Item | Why it waits |
| --- | --- |
| **Foreground service permissions** declarations (§5.2–5.4) | The Console derives the list of FGS types from the uploaded bundle's manifest. |
| **Sensitive app permissions** — `READ_PHONE_STATE` (§5.5) | Same: surfaced from the detected permission set. |
| **Pre-launch report** | Generated by running the uploaded bundle on Google's device farm. Expect cleartext and permission notes. |
| **Play App Signing** enrolment (§6.1) | Settled at the first release you create. |
| **Countries / regions, rollout** (§6.4) | Belong to a release, which needs a bundle. |
| Device / API-level availability warnings | Computed from the bundle. |

Everything else — listing, privacy policy, App access, Data safety, content
rating, target audience, and the News / COVID / Government / Financial / Health
/ Ads declarations — can be completed before any upload.

---

## §8 — What the SAF migration changed, and what is now stale

### 8.1 Console answers that would now be wrong

| Would-be answer | Correct answer now |
| --- | --- |
| Filling the **All files access** declaration form | **Do not fill it.** The permission is gone; the Console should not ask. If it asks, your AAB is stale (§5.1). |
| Recording and submitting the **demo video** for the restricted permission | Not required. The video existed only to support the All-files-access declaration. |
| Store listing wording implying broad storage access | The full description in §1.3 already says "Speakr only gets access to the folders you pick". Keep it that way. |
| Privacy policy claiming all-files access | The live policy describes the SAF model under "Auto-upload, folder access, and deletion of your files". It is correct; do not edit it to match an older doc. |

### 8.2 Data safety answers that did *not* change

Worth knowing so you don't second-guess yourself mid-form: **no Data safety
answer depended on all-files access.** What auto-upload reads and deletes — the
folders the user chose — is identical under SAF; only the permission mechanism
narrowed. Audio was already declared Collected. The migration narrows the
*mechanism*, not the *scope*, so every §4 answer stands.

### 8.3 Stale text in the other docs in this folder

These were written before PR #4 merged and now contradict the code. They do not
affect anything in this runbook, but do not copy from them:

1. **`permissions-declaration.md` §1** — "The code change ... lands in a
   **separate PR**. Until it merges, `AndroidManifest.xml:13` still declares the
   permission." Merged in #4; the manifest is clean. The same section's line
   numbers for the manifest are also now shifted.
2. **`permissions-declaration.md` §8** — the "sequencing" risk it describes is
   resolved; `main` is safe to build from.
3. **`checklist.md` §2, Privacy policy row** — "TODO (pending Pages)" and
   "Pending URL". The URL is **live (HTTP 200)**.
4. **`checklist.md` §4, `MANAGE_EXTERNAL_STORAGE` entry** — "the removal ships
   in a separate PR ... Do not upload an AAB built before that PR". Shipped.
5. **`checklist.md` §5 / §6** — the unchecked "SAF migration PR merged" box and
   follow-up item 1 ("Write & host the privacy policy") are both done.
6. **`data-safety.md`, intro bullet 5** — "`MANAGE_EXTERNAL_STORAGE` is being
   removed (the code change is in a separate PR; until it merges, builds from
   `main` still request it)". Removed.
7. **`data-safety.md`, confirm-item 4** — "The URL goes live once GitHub Pages
   is enabled". It is live.
8. **`listing.md`, Privacy policy URL section** — "`MANAGE_EXTERNAL_STORAGE` is
   being removed (the code change is in a separate PR)". Removed.

Separately, and **not** a SAF issue: `permissions-declaration.md` §6 and
`checklist.md` §4 both flag that `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` is
declared but never requested. That is still true at `main` and is being handled
by the permission audit — see §5.6.

---

## §9 — Final pre-submit sweep

- [ ] AAB built from a commit at or after PR #4; `MANAGE_EXTERNAL_STORAGE`
      absent from the Console's permission list on upload.
- [ ] AAB is release-signed, not debug-signed.
- [ ] `versionCode` higher than any previous upload.
- [ ] Privacy policy URL entered and still resolving.
- [ ] App access filled with a path a reviewer can actually walk (§2 — read
      §2.4 before you settle on Variant B).
- [ ] Data safety answers match §4, including the encryption-in-transit
      decision you made.
- [ ] Content rating questionnaire submitted; outcome is **Everyone**.
- [ ] Target audience is **18 and over** only.
- [ ] News / COVID-19 / Government / Financial / Health / Ads all answered.
- [ ] Foreground service declarations filled for every type the uploaded bundle
      actually declares — re-checked against `AndroidManifest.xml`, not against
      this document.
- [ ] `READ_PHONE_STATE` justification submitted.
- [ ] Review notes carry the cleartext explanation.
- [ ] Listing text, graphics and 5 screenshots uploaded.
- [ ] Countries and Free pricing set.
