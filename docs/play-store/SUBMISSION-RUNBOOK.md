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
- 🔒 **DECIDED** — a choice that was open in an earlier revision and has since
  been settled. The answer given is the answer; the reasoning is kept so you
  can defend it.
- ⏳ **AFTER AAB** — the form does not exist (or is not enforced) until a bundle
  has been uploaded. Skip on the first pass; see §6.

**Verified against the repo at `main` = `c9b9ef0`** (PRs #3–#9 merged; #9
was the last docs pass).
`android/app/src/main/AndroidManifest.xml` declares exactly nine permissions:
`INTERNET`, `RECORD_AUDIO`, `FOREGROUND_SERVICE`,
`FOREGROUND_SERVICE_MICROPHONE`, `FOREGROUND_SERVICE_MEDIA_PROJECTION`,
`WAKE_LOCK`, `READ_PHONE_STATE`, `RECEIVE_BOOT_COMPLETED`, `POST_NOTIFICATIONS`.
`MANAGE_EXTERNAL_STORAGE`, `READ_MEDIA_AUDIO`, `READ_EXTERNAL_STORAGE`,
`FOREGROUND_SERVICE_DATA_SYNC` and `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` are
**all absent** — the first was dropped in #4, the other four in the permission
audit (#7). `https://inrego.github.io/SpeakrApp/privacy-policy.html` returns
**HTTP 200**.

**Both decisions this runbook used to leave open are now settled:** App access
points the reviewer at a permanently hosted demo server,
`https://speakr-demo.renescott.dk` (§2), and "Data is encrypted in transit" is
answered **No** (§4.1).

---

## §0 — Before you open the Console

| Check | Why |
| --- | --- |
| The AAB you upload is built from a commit **at or after #7** (permission audit; #4 was the SAF migration). | An older bundle still carries permissions the app no longer declares — `MANAGE_EXTERNAL_STORAGE` before #4, and `READ_MEDIA_AUDIO` / `READ_EXTERNAL_STORAGE` / `FOREGROUND_SERVICE_DATA_SYNC` / `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` before #7. The Console reads the bundle, not the repo, and will demand declarations this runbook deliberately does not provide. `main` is clean today. |
| Re-read `android/app/src/main/AndroidManifest.xml` immediately before filling §5 (permission declarations). | The permission audit has **landed** (#7) and this runbook matches it: nine declared permissions, two foreground-service types. The manifest nevertheless stays the source of truth for which declaration forms you will be asked to fill — not this runbook, and not `permissions-declaration.md`. If the Console asks for a form §5 does not cover, stop and check the manifest. |
| Run the §2.2 probes against `https://speakr-demo.renescott.dk` before you open the App access form. | The demo server is a permanently hosted container, so there is nothing to start — but a URL that is down when the reviewer tries it fails the review, and the TLS certificate has a renewal date (§2.4). |
| Keystore backed up, passwords recorded. | Losing the upload key blocks every future update. The four CI secrets are `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`. |
| Confirm the AAB is **not** debug-signed. | `android/app/build.gradle.kts` silently falls back to the debug signing config when `android/key.properties` is absent. CI has a guard step that fails the job if a signing secret is missing; a local build has no such guard. |

### Recommended order

The Console lets you do most of these in any order, but this order minimises
rework — and step 2 is **not optional**, it is a hard gate the Console enforces:

1. **Upload an AAB to Internal testing first** (§6.2), *without* rolling it out.
   This makes the Console read your manifest, which unlocks the pre-launch
   report and the ordering of the ⏳ items. Note that the §5 declaration forms
   still do not appear on a saved draft — they are requested at submission time
   (§2.6).
2. **Fill App access (§2) next.** Sign in details (App access) **gates Target
   audience and content (§3.4), which in turn gates submitting Data safety
   (§4).** Skipping ahead just means coming back.
3. Then work the rest of §1 → §4 below.
4. Then come back and finish the release (§6).

If you prefer to fill the paperwork first, that works too — just expect the ⏳
items to be missing until step 1 happens, and App access to block §3.4 and §4
until step 2 happens.

---

## §1 — Store listing

**Where:** Grow users → Store presence → **Main store listing**

### 1.1 App name (max 30 chars)

```
Minutes for Speakr
```

**Why:** 18 chars. The app is an unofficial client, so it must not be titled
plain "Speakr" (impersonation / IP risk, sharper for a paid app); "for Speakr"
states compatibility. Launcher label is the short form `android:label="Minutes"`.

### 1.2 Short description (max 80 chars)

```
Record & transcribe meetings on your own self-hosted Speakr server.
```

**Why:** 67 chars; leads with the self-hosted requirement so the listing sets
expectations before install.

### 1.3 Full description (max 4000 chars)

```
Minutes for Speakr is a client for the self-hosted, open-source Speakr
transcription and meeting-notes server. It records, uploads, and reviews AI-transcribed
meetings — and it talks ONLY to the Speakr instance you configure.

IMPORTANT: This is an independent, unofficial app. It is not affiliated with or
endorsed by the Speakr server project, and it is not a standalone service. You must run (or have access to) your own Speakr server
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
• On Android you choose each folder in the system folder picker; Minutes only
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
  device's own folder picker. Minutes requests no other storage access.

Minutes is cross-platform: Android, iOS, and Windows desktop. (iOS builds are
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
the free-text field. **That free-text field caps at 500 characters** (measured
in the live Console, 2026-09-25) — §2.3 gives text that fits.

Because Speakr has no username/password, put the **Server URL** in the username
field and the **API Token** in the password field, and say so in the text.

**Do App access first.** In the current Console, **Sign in details (App access)
gates Target audience and content, which in turn gates submitting Data
safety.** Neither downstream form will let you finish until this one is saved.
§0's recommended order is written accordingly.

### 2.1 🔒 DECIDED: the reviewer connects to a permanently hosted demo server

**Decided 2026-09-25, superseding the temporary Cloudflare quick tunnel that
earlier revisions of this runbook specified.** The mock server now runs as a
**permanent Docker container on an Oracle arm64 (Ampere A1) VPS**, created with
**Dockhand** and fronted by **Caddy**. It is reachable at:

```
https://speakr-demo.renescott.dk
```

Paste it **without a trailing slash**. The API token is unchanged:
`speakr-demo-token`. The mock server accepts any non-empty `X-API-Token` (or
`Authorization: Bearer ...`), so a mistyped token still gets the reviewer in; an
absent one does not.

What this buys, against the tunnel that was decided before:

- **No daily babysitting.** There is no process on your laptop to keep alive and
  no hostname that changes when something restarts.
- **No re-pasting between reviews.** The same URL is valid for the initial
  submission and for every future update review, so §2.3 is written once.
- **Real TLS.** Caddy serves a Let's Encrypt wildcard certificate for
  `*.renescott.dk`, so the reviewer's connection is HTTPS end to end on a
  publicly trusted chain. No cleartext exception is involved here — §5.7 is
  about the *app's* support for LAN servers, not about this endpoint.

The container assets live in the repo, so the deployment is reproducible:
`tools/mock-server/Dockerfile`, `tools/mock-server/.dockerignore`,
`tools/mock-server/compose.yaml`, `tools/mock-server/Caddyfile.example`, and the
container health probe `tools/mock-server/bin/healthcheck.dart`.

The old fallback — telling the reviewer to install the Dart SDK, clone the repo
and run the server on their own machine — is **not** submitted. It is kept in
[Appendix A](#appendix-a--fallback-reviewer-runs-the-server-themselves) only in
case the hosted endpoint ever becomes impossible.

### 2.2 Verify the endpoint before you paste it

Nothing has to be started — the container runs whether or not you are at your
desk. You are only confirming it is healthy on the day you submit.

**Health probe (no token needed).** `GET /` is unauthenticated:

```bash
curl -s https://speakr-demo.renescott.dk/
```

Expect `{"service":"speakr-mock-server","recordings":6}`.

**Authenticated probe.**

```bash
curl -s -o /dev/null -w '%{http_code}\n' \
  -H 'X-API-Token: speakr-demo-token' \
  https://speakr-demo.renescott.dk/api/v1/recordings
```

Expect `200`. Anything else, fix it before you paste — a URL that 404s or times
out in the App access field is a guaranteed rejection.

All of the following were verified on 2026-09-25:

| Request | Result |
| --- | --- |
| `GET /api/v1/recordings` with the token | **200**, six recordings |
| `GET /api/v1/recordings` with no token | **401** |
| `GET /api/v1/recordings/101` with the token | **200** |
| `http://speakr-demo.renescott.dk/…` | **308** redirect to HTTPS |
| The real Flutter app in an Android emulator | Onboarding connected; library showed "6 total"; detail view rendered summary and transcript; no TLS or cleartext errors in logcat |

A **doubled slash** (`https://speakr-demo.renescott.dk//api/v1/...`) 404s at the
HTTP level, so do not paste a trailing slash. The app itself is unaffected
either way — `lib/features/onboarding/onboarding_screen.dart:42-43` strips one
trailing slash before storing the URL — but the Console text should be the clean
form.

### 2.3 What to paste into App access

Entry name:

```
Speakr demo server
```

Username field (the app has no username; the Server URL goes here):

```
https://speakr-demo.renescott.dk
```

Password field (the app has no password; the API token goes here):

```
speakr-demo-token
```

Any other instructions — **this is the text actually submitted**, 313
characters, inside the 500-character cap:

```
No accounts: the server URL and API token above are the credentials.

Launch the app, tap Next through the intro screens, then enter the Server URL and API Token on the connection screen. The library opens with demo recordings.

Demo server with fictional data, stood up for this review only. Problems: rss@khd.dk
```

The longer walkthrough that earlier revisions of this runbook put here **does
not fit** — it ran to roughly 1400 characters. Everything in it that is still
worth telling a reviewer belongs in the release **review notes** (§6.3), which
has no such limit: what the app is for, that the developer operates no backend,
that the "+" action on the library screen opens the live recorder and that
Android will ask for microphone permission (and, only if the system-audio
source is switched on, for its screen-capture consent), and that audio only —
never screen content — is captured.

### 2.4 Keeping the endpoint healthy

There is no ephemerality left to manage, but two things can still take the
endpoint down quietly:

- **Certificate expiry.** The Let's Encrypt wildcard for `*.renescott.dk`
  **expires 2026-12-13**. Confirm Caddy's automatic renewal is actually working
  rather than assuming it — a lapsed certificate breaks the endpoint silently
  for any later update review, and the first you would hear of it is a
  rejection.
- **Container or host restart.** Check that `compose.yaml`'s restart policy
  survives a VPS reboot. The `GET /` probe in §2.2 is the cheapest confirmation;
  it needs no token and returns the recording count.

Re-run the §2.2 probes on the day you submit, and again if you are ever rejected
for inability to access the app — a dead endpoint would be the most likely cause
and the cheapest to fix.

### 2.5 After approval: nothing to tear down

The endpoint stays up. It is a demo instance holding entirely fictional data in
memory, writing nothing to disk, with nothing to protect — so there is no cost
to leaving it running and a real cost to taking it down: **every future update
review needs the same App access entry**, and a stable URL means §2.3 is never
re-pasted.

If the endpoint is ever retired, update the App access entry *before* the next
submission, not after.

### 2.6 Console findings this runbook did not anticipate

Recorded from the live Console on 2026-09-25. These are facts about the forms,
not decisions being re-opened.

- **Ordering.** Sign in details (App access) gates **Target audience and
  content** (§3.4), which gates submitting **Data safety** (§4). Do App access
  first.
- **Advertising ID declaration.** App content contains an **Advertising ID**
  declaration that §3 never mentions. It is required. Answered **No** — the
  merged manifest declares no `AD_ID` permission.
- **Data safety — "Can users log in to your app with accounts created outside of
  the app?"** Answered **No**. A server URL and an API token are not an account:
  there is no identity, no sign-up and no sign-out.
- **IARC questionnaire — "Online Content".** Answered **No**, even though its
  examples name "generated AI content". The summaries are generated by the
  user's own server from the user's own audio; the app surfaces no content from
  other users and none from a developer-operated service.
- **§5's declaration forms did not appear at all** for a saved **Internal
  testing draft.** The foreground-service and `READ_PHONE_STATE` declarations
  are requested **at submission time**, not on upload. Do not go hunting for
  forms that are not there yet — §5's ⏳ means "after an AAB *and* at
  submission", not "immediately after upload".

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
| Is all of the user data collected by your app encrypted in transit? | 🔒 **DECIDED — No** | **Settled 2026-09-22; answer No.** `android:usesCleartextTraffic="true"` (`AndroidManifest.xml:38`) is deliberate, so users can reach self-hosted `http://` servers on their own LAN. HTTPS does work — and is what happens whenever the user's server has TLS — but the checkbox is all-or-nothing, and because plain HTTP is a supported, intended path, **Yes** would be an untrue statement in a legally binding form. The cost of **No** is a "Data isn't encrypted in transit" line on the store listing, which is honest for a LAN-first self-hosted client and which the free text in §4.6 explains. *The only thing that could flip this to Yes is enforcing HTTPS in a future build, which would break LAN users.* |
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
| Is data encrypted in transit? | **No** (the settled §4.1 answer) | Cleartext HTTP is a supported path for self-hosted LAN servers, so the all-or-nothing box cannot honestly be ticked. |
| Do you provide a way for users to request data deletion? | **Yes** | On their own server or device; no developer-held data. |
| Have you committed to follow the Play Families Policy? | **No / N/A** | Not a children's app (§3.4). |
| Has your app been independently validated against a global security standard? | **No** | No review has been performed. |

### 4.6 Free text / additional context

Paste this wherever the form offers an explanation field (not in the review
notes; see §6.3):

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
Expect them to be absent or greyed out until an AAB is in a track (§6) — and
note that, verified 2026-09-25, they did **not** appear even then for a saved
Internal-testing draft. They are requested **at submission time** (§2.6), so do
not go looking for them earlier.

> **The permission audit has landed (#7) and this section matches the shipping
> manifest.** Exactly two foreground-service types are declared —
> `microphone` and `mediaProjection`, both on the one service
> `.audio.AudioCaptureService` — plus the sensitive `READ_PHONE_STATE`. The
> Console will ask about exactly what is in the bundle you uploaded, no more and
> no less. If it asks for a form not covered below, stop and re-read
> `android/app/src/main/AndroidManifest.xml` rather than improvising.

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

### 5.4 ~~Foreground service — Data sync~~ — WITHDRAWN 2026-09-22

**Do not fill in a Data sync foreground-service declaration.**
`android.permission.FOREGROUND_SERVICE_DATA_SYNC` was **removed from the
manifest in the permission audit (#7) on 2026-09-22** and is absent at `main`.

**Why it went:** the app declares no service with
`foregroundServiceType="dataSync"` — the only app-declared service is
`.audio.AudioCaptureService` (`mediaProjection|microphone`). WorkManager runs
the auto-upload job as ordinary, non-expedited work (`lib/main.dart`, no
`outOfQuotaPolicy`), so `androidx.work`'s `SystemForegroundService` is never
started and carries no `foregroundServiceType` in the merged manifest. The
permission backed a code path that does not exist.

**If the Console asks for this form anyway, your AAB predates #7 — rebuild, do
not fill the form.** The previously drafted justification text is withdrawn, not
merely unused: submitting it would justify a foreground-service type the app
does not run.

### 5.5 `READ_PHONE_STATE`

**Where:** App content → Sensitive app permissions (phone group).

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

### 5.6 ~~`REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`~~ — WITHDRAWN 2026-09-22

**Nothing to declare. Skip this item.**
`android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` was **removed from
the manifest in the permission audit (#7) on 2026-09-22** and is absent at
`main`.

**Why it went:** nothing in the app ever requested it — no
`Permission.ignoreBatteryOptimizations` call and no
`ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` intent anywhere in `lib/` or
`android/`. It was dead weight carried from the initial commit, and Play
discourages requesting it directly in any case. Removing it deleted a policy
question for free.

The justification text that once sat in `permissions-declaration.md` §6 is
**withdrawn** — it described a user-tapped exemption flow the app never had.

### 5.7 Cleartext traffic — review note, not a form

There is no Console form for this. The release **review notes** (§6.3) carry it
as one sentence; the text below is background if a reviewer asks for more.

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
| Bundle | the `.aab` from the release workflow (`dist/MinutesForSpeakr-<version>.aab`) |
| `versionCode` | GitHub Actions run number — must be strictly higher than any previous upload |
| Universal APK | **do not upload** — it is for direct GitHub download only |

Watch the Console's permissions summary on upload: none of the five removed
permissions (§8.4) may appear. `MANAGE_EXTERNAL_STORAGE` means the bundle
predates PR #4; any of the other four means it predates PR #7. Either way —
rebuild, do not fill the form it asks for.

### 6.3 Release notes and review notes

Release notes (user-facing) are your call. If the release page offers a
**review notes** field (internal, for the reviewer), paste this — it may not
exist, in which case App access and the §5 declaration forms are the only
reviewer channels and nothing is lost:

```
Speakr is a client for a transcription server the user hosts themselves; the developer runs no backend. Demo server URL and token are under App access.

To test recording: tap + on the library screen. Android asks for microphone permission; if the optional system-audio source is switched on, it also shows its per-session screen-capture consent. Only audio is captured, never screen content.

Cleartext HTTP is enabled on purpose: many users run their server on a home/office LAN at http:// with no certificate.
```

Do **not** paste the §4.6 Data safety text, the §5.3 media-projection text or the
§5.5 `READ_PHONE_STATE` text here as well. Each is judged in its own form, so a
second copy adds nothing.

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
| **Foreground service permissions** declarations (§5.2–5.3 — microphone and media projection only) | The Console derives the list of FGS types from the uploaded bundle's manifest. Verified 2026-09-25: still absent on a *saved* Internal-testing draft — requested at submission time (§2.6). |
| **Sensitive app permissions** — `READ_PHONE_STATE` (§5.5) | Same: surfaced from the detected permission set, and likewise only at submission time. |
| **Pre-launch report** | Generated by running the uploaded bundle on Google's device farm. Expect cleartext and permission notes. |
| **Play App Signing** enrolment (§6.1) | Settled at the first release you create. |
| **Countries / regions, rollout** (§6.4) | Belong to a release, which needs a bundle. |
| Device / API-level availability warnings | Computed from the bundle. |

Everything else — listing, privacy policy, App access, Data safety, content
rating, target audience, the Advertising ID declaration (§2.6), and the News /
COVID / Government / Financial / Health / Ads declarations — can be completed
before any upload. Within that set the Console still imposes its own order: App
access before target audience before Data safety (§2.6).

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

### 8.3 Stale text in the other docs — all cleared 2026-09-22

The eight passages listed here were written before PR #4 merged and contradicted
the code. **They have all been corrected in place**; the list is kept so you can
see what changed and check the work.

| # | Passage | Resolution |
| --- | --- | --- |
| 1 | `permissions-declaration.md` §1 — "the code change … lands in a **separate PR**. Until it merges, `AndroidManifest.xml:13` still declares the permission." | Fixed. The intro now records #4 as merged, and every manifest line reference in that file was re-pointed at the current file. |
| 2 | `permissions-declaration.md` §8 — the unresolved "sequencing" risk. | Fixed. §8 now states that `main` is safe to build from, and that all five removed permissions are gone. |
| 3 | `checklist.md` §2, Privacy policy row — "TODO (pending Pages)", "Pending URL". | Fixed. The row is **DONE** and the URL is recorded as live (HTTP 200). |
| 4 | `checklist.md` §4, `MANAGE_EXTERNAL_STORAGE` entry — "the removal ships in a separate PR … Do not upload an AAB built before that PR". | Fixed. Rewritten as shipped in #4, with the AAB caveat kept as a build-provenance check rather than a pending code change. |
| 5 | `checklist.md` §5 / §6 — unchecked "SAF migration PR merged" box and follow-up 1 ("Write & host the privacy policy"). | Fixed. Both are now ticked and struck respectively. |
| 6 | `data-safety.md`, intro bullet 5 — "`MANAGE_EXTERNAL_STORAGE` is being removed (the code change is in a separate PR …)". | Fixed. The bullet now records the removal as shipped, and adds that the permission audit removed the last two storage permissions as well. |
| 7 | `data-safety.md`, confirm-item 4 — "The URL goes live once GitHub Pages is enabled". | Fixed. Recorded as live. |
| 8 | `listing.md`, Privacy policy URL section — "`MANAGE_EXTERNAL_STORAGE` is being removed (the code change is in a separate PR)". | Fixed. Rewritten as removed, with the SAF model described in the present tense. |

Two further stale passages were found beyond that list and fixed at the same
time:

- **`listing.md` and §1.3 above, REQUIREMENTS bullet** — "Audio/storage access
  to read files you want to upload" described a storage permission the app no
  longer declares on Android. Rewritten.
- **`RELEASE_READINESS.md`, permission-audit note** — the merged-manifest
  permission arithmetic did not add up, and the note said
  `permissions-declaration.md` "has not been rewritten". Both corrected.

### 8.4 What the permission audit (#7) made stale, and what it changed

Four permissions were removed on 2026-09-22 after every declared permission was
re-checked against the code and against the merged manifest from a real
`flutter build apk`:

| Removed | Why it was unreachable |
| --- | --- |
| `READ_MEDIA_AUDIO` | All Android audio I/O goes through the SAF tree grant. The app has **no single-file picker on Android** — `file_picker` is used only for `getDirectoryPath()`. |
| `READ_EXTERNAL_STORAGE` (`maxSdkVersion 32`) | Same. No storage permission of any kind is left. |
| `FOREGROUND_SERVICE_DATA_SYNC` | No `dataSync` service exists; WorkManager runs non-expedited (§5.4). |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Never requested anywhere in the code (§5.6). |

**What this changes for you:** two Console declaration forms disappear (§5.4,
§5.6). Nothing in §4 (Data safety) moves — the audit narrowed *which permissions
back* the auto-upload behaviour, not what the app reads, transmits or deletes.
Audio was already declared Collected and stays so.

**One thing to watch at upload:** the Console's permission summary should list
nine app permissions plus `ACCESS_NETWORK_STATE` and the `androidx.core`
dynamic-receiver permission, which dependencies contribute. If it lists any of
the five removed permissions, your AAB predates #7 — rebuild.

---

## §9 — Final pre-submit sweep

- [ ] AAB built from a commit at or after PR #7; `MANAGE_EXTERNAL_STORAGE`,
      `READ_MEDIA_AUDIO`, `READ_EXTERNAL_STORAGE`,
      `FOREGROUND_SERVICE_DATA_SYNC` and
      `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` all absent from the Console's
      permission list on upload.
- [ ] AAB is release-signed, not debug-signed.
- [ ] `versionCode` higher than any previous upload.
- [ ] Privacy policy URL entered and still resolving.
- [ ] `https://speakr-demo.renescott.dk` answers both §2.2 probes — `GET /`
      returns `{"service":"speakr-mock-server","recordings":6}` and
      `/api/v1/recordings` with the token returns **200** (re-check on the day
      you submit).
- [ ] Caddy's Let's Encrypt renewal confirmed working; the `*.renescott.dk`
      certificate expires **2026-12-13** (§2.4).
- [ ] App access filled **first** — it gates §3.4, which gates §4 (§2.6).
      Server URL in the username field with **no trailing slash**, token in the
      password field, and the 313-character instructions text from §2.3 (the
      field caps at 500).
- [ ] Advertising ID declaration answered **No** (§2.6) — it is required and
      §3 does not list it.
- [ ] Data safety answers match §4, with encryption in transit answered **No**
      (§4.1).
- [ ] Content rating questionnaire submitted; outcome is **Everyone**.
- [ ] Target audience is **18 and over** only.
- [ ] News / COVID-19 / Government / Financial / Health / Ads all answered.
- [ ] Foreground service declarations filled for **microphone** and
      **media projection** only — and re-checked against `AndroidManifest.xml`,
      not against this document. There is no Data sync declaration to file
      (§5.4) and no battery-optimisation item (§5.6).
- [ ] Console permission summary on upload shows none of the five removed
      permissions (§8.4).
- [ ] `READ_PHONE_STATE` justification submitted.
- [ ] Review notes carry the cleartext explanation.
- [ ] Listing text, graphics and 5 screenshots uploaded.
- [ ] Countries and Free pricing set.
- [ ] After approval: **nothing to tear down** — the demo endpoint stays up for
      future update reviews (§2.5).

---

## Appendix A — FALLBACK: reviewer runs the server themselves

**Do not submit this. It is not the chosen path.** The decided route is the
permanently hosted demo server in §2. This appendix is kept only so that, if
that endpoint ever becomes impossible, you are not rewriting the text under time
pressure — and so the reasons it was rejected stay on the record.

### A.1 The entry, if you ever have to use it

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

Verify the clone URL before pasting. The repo must be **public** at review time
or step 2 fails outright.

### A.2 Why it was not chosen

- It asks a reviewer to install a language SDK, clone a git repo, and run a
  server process on their own machine. Play review is a high-throughput
  process; instructions that require developer tooling on the reviewer's host
  are outside what the App access field is designed for.
- It assumes the reviewer uses an emulator on a machine they control, and that
  `10.0.2.2` applies. If review runs on a physical device farm, `10.0.2.2` is
  wrong and the LAN-IP fallback is unreachable from their network.
- There is **no prebuilt mock-server binary published anywhere today** —
  `.github/workflows/release.yml` builds only the AAB and the universal APK. So
  "download and run" is not an option; it is "install Dart and build it".
- The likely outcome is a rejection citing inability to access app
  functionality. That costs a review cycle (days), and repeated access
  rejections are worse than a single delay.

The hosted endpoint in §2 keeps the reviewer's path to one screen of typing,
which is why it won. It also carries none of the ephemerality that the earlier
quick-tunnel decision did: the URL is stable across reviews, and the only upkeep
is certificate renewal (§2.4).
