# Speakr App

A Flutter client for [Speakr](https://github.com/learnedmachine/speakr), the self-hosted audio transcription and meeting-notes server. Runs on **Android**, **iOS**, and **Windows desktop**.

Record meetings live, upload existing audio, watch transcription progress, then read AI-generated summaries with speaker-attributed transcripts — all against your own Speakr instance.

## Features

- **Live recording** with a tag picker, pause/resume, and a Windows always-on-top mini recorder that survives switching apps.
- **Upload existing audio** (m4a, mp3, wav, …) with optional min/max speakers, language, tags, meeting date, and notes.
- **Auto-upload** watcher (Android + Windows): drop files into a folder and they upload in the background via `workmanager`.
- **Auto-record** (Windows): start recording automatically when system audio or the mic crosses a threshold — implemented in pure-Dart FFI, no native build glue.
- **Library** with live status badges (`PENDING → PROCESSING → SUMMARIZING → COMPLETED`).
- **Detail view** with three tabs: Markdown summary, speaker-attributed transcript, and metadata.
- **Speaker review**: rename speakers with autocomplete from your global speaker list and per-segment suggestion chips.
- **Auth** via `X-API-Token` stored in OS secure storage (Keychain / Keystore / Windows Credential Manager).

## Screenshots

_Screenshots and a short demo clip live in [`docs/`](docs/) — drop your own in there before publishing._

## Requirements

- Flutter SDK **^3.11.0** (Dart 3.11+)
- A reachable Speakr server (REST API v1) and an API token from its **Account → API Tokens** page
- Platform toolchains for whichever targets you build:
  - Android: Android Studio + Android SDK 21+
  - iOS: Xcode on macOS (untested in CI — see _Known limitations_)
  - Windows: Visual Studio 2022 with the "Desktop development with C++" workload

## Getting started

```bash
git clone https://github.com/<your-fork>/speakr-app.git
cd speakr-app

flutter pub get
dart run build_runner build --delete-conflicting-outputs

# Run on the platform of your choice
flutter run -d windows
flutter run -d <android-device-id>
flutter run -d <ios-device-id>
```

On first launch the app shows an **Onboarding** screen. Enter:

1. Your Speakr server URL (e.g. `https://speakr.example.com`)
2. An API token

Both are stored via `flutter_secure_storage` and never logged. The app talks only to the server you configure — there is no hard-coded backend.

## Building releases

```bash
# Windows
flutter build windows --release

# Android (arm64)
flutter build apk --release --target-platform android-arm64

# iOS (requires macOS + signing)
flutter build ipa --release
```

The Windows app icon is generated from [`speakr-mark-square.svg`](speakr-mark-square.svg) by `tools/build_icon_sources.dart`, which embeds 16/24/32/48/64/128/256 sub-images rendered fresh from the SVG (rather than downscaling a single PNG). Re-run it if the mark changes.

## Project layout

```
lib/
├── main.dart, app.dart        # bootstrap + ProviderScope + MaterialApp.router
├── api/                       # Dio client, auth interceptor, freezed DTOs
├── theme/                     # SpeakrColors, SpeakrText, ThemeData
├── routing/                   # go_router with credential-based redirect
├── services/                  # secure storage, auto-record FFI, ...
├── widgets/                   # MonoEyebrow, TagChip, MiniWave, StatusBadge, ...
├── utils/                     # formatters
└── features/
    ├── onboarding/  library/  detail/{tabs/}
    ├── live/{mini/, widgets/}
    ├── auto_upload/   settings/
```

Feature folders never import from each other — they go through `lib/api`, `lib/services`, or `lib/widgets`.

## Stack

| Concern         | Choice                                                     |
| --------------- | ---------------------------------------------------------- |
| State           | `flutter_riverpod` (hand-rolled providers, no codegen)     |
| Networking      | `dio` + `AuthInterceptor`                                  |
| API client      | Hand-rolled against `openapi/speakr-openapi.json`          |
| Models          | `freezed` + `json_serializable`                            |
| Routing         | `go_router`                                                |
| Secure storage  | `flutter_secure_storage`                                   |
| Audio playback  | `just_audio` (auth header passed via `setUrl`)             |
| Audio capture   | `record` (AAC m4a in temp dir, deleted after upload)       |
| Multi-window    | `desktop_multi_window` (Windows mini recorder)             |
| Background jobs | `workmanager` (auto-upload watcher)                        |
| Markdown        | `flutter_markdown_plus` (summary tab)                      |

See [`AGENTS.md`](AGENTS.md) for the rationale behind each choice and the pitfalls we have already paid for.

## Development

```bash
flutter analyze            # must be clean before merge
flutter test
dart run build_runner build --delete-conflicting-outputs   # after editing freezed models
```

The OpenAPI spec at [`openapi/speakr-openapi.json`](openapi/speakr-openapi.json) is the source of truth for endpoints. The Dart client is hand-rolled — when you add an endpoint, mirror the `_get` / `_post` / `_unwrap` helpers in [`lib/api/speakr_api.dart`](lib/api/speakr_api.dart).

## Known limitations

- **iOS** builds compile but have not been verified end-to-end (no Mac in CI).
- **Linux** is not a supported target. `record_linux` is pinned via `dependency_overrides` only so the Windows desktop build resolves.
- **Google Fonts** are fetched at runtime on first launch. Bundle the TTFs as assets before shipping a real release if you need offline-first font rendering.
- No offline cache, no resumable uploads, no push notifications when transcription finishes — the Library re-polls on refresh.

## Contributing

Please read [`AGENTS.md`](AGENTS.md) before opening a PR. It documents the dependency pins, the lints we have intentionally disabled, and a few traps that are easy to fall into (notably: do **not** add `riverpod_generator` — the analyzer plugin it pulls in breaks `build_runner` on Dart 3.11).

## License

This client is not affiliated with the Speakr server project. Add a `LICENSE` file before publishing.
