# Bundled fonts

These are the three families the Speakr client renders with. They are bundled as
assets (declared under `flutter: fonts:` in `pubspec.yaml`) so the app never
reaches a font CDN at runtime — a cold first launch on an offline or LAN-only
device renders correctly, and no request leaves the device.

The `google_fonts` package was removed from `pubspec.yaml` when these landed.
Do not reintroduce it; add a static TTF here instead.

## What is shipped, and why only this

Only the weights and styles that `lib/theme/typography.dart` and its call sites
actually ask for are bundled. Every unused face is dead weight in the APK/AAB.

| File | Family | Weight | Style | Bytes |
| --- | --- | --- | --- | --- |
| `SourceSerif4-Light.ttf` | Source Serif 4 | 300 | normal | 194,484 |
| `SourceSerif4-Regular.ttf` | Source Serif 4 | 400 | normal | 194,440 |
| `SourceSerif4-Italic.ttf` | Source Serif 4 | 400 | italic | 183,528 |
| `SourceSerif4-Medium.ttf` | Source Serif 4 | 500 | normal | 194,692 |
| `SourceSerif4-SemiBold.ttf` | Source Serif 4 | 600 | normal | 194,776 |
| `InterTight-Regular.ttf` | Inter Tight | 400 | normal | 298,236 |
| `InterTight-Italic.ttf` | Inter Tight | 400 | italic | 304,804 |
| `InterTight-Medium.ttf` | Inter Tight | 500 | normal | 301,448 |
| `InterTight-SemiBold.ttf` | Inter Tight | 600 | normal | 302,188 |
| `JetBrainsMono-Regular.ttf` | JetBrains Mono | 400 | normal | 112,148 |
| `JetBrainsMono-Medium.ttf` | JetBrains Mono | 500 | normal | 112,180 |

Total: 2,392,924 bytes (≈2.28 MiB) uncompressed. TTFs are compressed in the
AAB, so the shipped delta is smaller.

If you add a `SpeakrText.serif/sans/mono` call with a weight or style not in the
table above, Flutter picks the nearest declared face and synthesises the
difference — it will look subtly wrong rather than fail. Add the matching static
TTF here and register it in `pubspec.yaml` instead.

## Provenance

These are **static instances**, not variable fonts. Flutter applies `fontWeight`
by selecting a declared face; it does not interpolate a variable font's `wght`
axis unless you pass `fontVariations` explicitly. Static per-weight files are
therefore the only way to get the intended weights to render.

Upstream `google/fonts` now publishes these three families as variable TTFs
only. The files here are the exact static instances that the `google_fonts`
package used to download at runtime, fetched from
`https://fonts.gstatic.com/s/a/<sha256>.ttf` using the hashes in the
`google_fonts` 8.1.0 manifest and verified against that manifest's recorded
sha256 and byte length. That makes the bundled rendering byte-identical to what
the app produced before, including the screenshots in `docs/screenshots/`.

## Licensing

All three families are licensed under the SIL Open Font License 1.1. The full
license text ships alongside the fonts:

- `OFL-SourceSerif4.txt` — Copyright 2014 The Source Serif 4 Project Authors
- `OFL-InterTight.txt` — Copyright 2022 The Inter Project Authors
- `OFL-JetBrainsMono.txt` — Copyright 2020 The JetBrains Mono Project Authors

The OFL requires the license and copyright notice to accompany the font files.
Keep these three files next to the TTFs.
