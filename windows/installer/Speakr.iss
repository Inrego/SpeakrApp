; Speakr - Inno Setup installer script
;
; Packages the output of `flutter build windows --release`
; (build\windows\x64\runner\Release\) into a Windows installer.
;
; The version is supplied on the ISCC command line, e.g.:
;     iscc /DMyAppVersion=1.2.3 windows\installer\Speakr.iss
; When no /D is given it falls back to the placeholder default below.
;
; The build is UNSIGNED: Windows SmartScreen may warn on first run.
; Do not attempt code signing here.

#ifndef MyAppVersion
  #define MyAppVersion "0.0.0"
#endif

#define MyAppName "Speakr"
#define MyAppPublisher "Rene Scott Simonsen"
#define MyAppExeName "speakr_app.exe"
#define MyAppURL "https://github.com/Inrego/SpeakrApp"

[Setup]
; A fixed AppId GUID kept constant across releases so upgrades work.
; (Inno requires the doubled leading brace.)
AppId={{B8E6F2A4-3C1D-4E5F-9A7B-2D6C8F0E1A3B}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\Speakr
DefaultGroupName=Speakr
DisableProgramGroupPage=yes
; Windows 10 (1809) and newer; Flutter Windows is x64-only.
MinVersion=10.0.17763
; Use the classic `x64` identifier: it compiles on every Inno Setup 6.x.
; (The newer `x64compatible` requires Inno Setup 6.3+, which is not guaranteed
; to be the version preinstalled on GitHub windows runners, where the CI's
; `choco install innosetup` step only runs as a fallback when iscc is absent.)
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
OutputBaseFilename=Speakr-Setup-{#MyAppVersion}
SetupIconFile=..\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
UninstallDisplayName={#MyAppName}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
; Stamp the produced setup .exe with version info.
VersionInfoVersion={#MyAppVersion}
VersionInfoProductVersion={#MyAppVersion}
VersionInfoCompany={#MyAppPublisher}
VersionInfoProductName={#MyAppName}
VersionInfoDescription={#MyAppName} Setup

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Package the entire Release runner folder (exe, all DLLs, and data\).
; Path is relative to this .iss file in windows\installer\.
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
