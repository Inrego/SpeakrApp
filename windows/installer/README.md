# Windows installer (Inno Setup)

`Speakr.iss` is an [Inno Setup](https://jrsoftware.org/isinfo.php) script that
packages the output of `flutter build windows --release` into a Windows
installer named `Speakr-Setup-<version>.exe`.

## What it packages

The whole Release runner folder, recursively:

```
build\windows\x64\runner\Release\
  speakr_app.exe       (the app)
  *.dll                (Flutter engine + plugin DLLs)
  data\                (icudtl.dat, flutter_assets\, app.so)
```

Everything in that directory is installed under `{autopf}\Speakr`
(e.g. `C:\Program Files\Speakr`). The installer adds a Start Menu shortcut,
an optional desktop icon, and a standard uninstaller.

## Prerequisites

1. Build the app first so the Release folder exists:
   ```
   flutter build windows --release --build-name=X.Y.Z --build-number=N
   ```
2. The Inno Setup compiler `iscc` (Inno Setup 6+). It ships on GitHub
   `windows-latest` runners; if missing, install via Chocolatey:
   ```
   choco install innosetup -y
   ```

## How CI invokes it

Run `iscc` from the repo root, passing the release version with `/D` so the
`OutputBaseFilename` and the embedded version info match the tag:

```
iscc /DMyAppVersion=X.Y.Z windows\installer\Speakr.iss
```

`X.Y.Z` is the Git tag without the leading `v` (the same value passed to
`--build-name`). When `/DMyAppVersion` is omitted, the script falls back to a
`0.0.0` placeholder.

The compiled installer is written to `windows\installer\Output\Speakr-Setup-X.Y.Z.exe`.
CI uploads it to the GitHub Release alongside the portable
`Speakr-<version>-windows-x64.zip`.

## Unsigned build

The app and installer are **not** code-signed. On first launch Windows
SmartScreen may show a "Windows protected your PC" warning; users click
**More info → Run anyway**. No code signing is performed in CI.
