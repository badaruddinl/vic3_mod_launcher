#define AppName "Victoria 3 Mod Launcher"
#define AppPublisher "badaruddinl"
#define AppExeName "vic3_mod_launcher.exe"

#ifndef AppVersion
  #define AppVersion "1.0.0"
#endif

#ifndef AppFileVersion
  #define AppFileVersion "1.0.0.0"
#endif

#ifndef ReleaseDir
  #error ReleaseDir must be passed by build_installer.ps1
#endif

#ifndef OutputDir
  #error OutputDir must be passed by build_installer.ps1
#endif

#ifndef IconFile
  #error IconFile must be passed by build_installer.ps1
#endif

[Setup]
AppId={{8B6F3528-FA4F-4E2F-B7E4-A36664E7D723}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher={#AppPublisher}
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=no
OutputDir={#OutputDir}
OutputBaseFilename=Vic3ModLauncher-Setup
SetupIconFile={#IconFile}
UninstallDisplayIcon={app}\{#AppExeName}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
CloseApplications=yes
RestartApplications=no
SetupLogging=yes
VersionInfoCompany={#AppPublisher}
VersionInfoDescription={#AppName} Setup
VersionInfoProductName={#AppName}
VersionInfoProductVersion={#AppVersion}
VersionInfoVersion={#AppFileVersion}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Dirs]
Name: "{app}\data"; Attribs: hidden
Name: "{app}\data\flutter_assets"; Attribs: hidden

[InstallDelete]
Type: files; Name: "{app}\Vic3ModLauncher-Setup.exe"
Type: files; Name: "{app}\Vic3ModLauncher-Uninstall.exe"

[Files]
Source: "{#ReleaseDir}\{#AppExeName}"; DestDir: "{app}"; Flags: ignoreversion restartreplace uninsrestartdelete
Source: "{#ReleaseDir}\*.dll"; DestDir: "{app}"; Flags: ignoreversion restartreplace uninsrestartdelete; Attribs: hidden
Source: "{#ReleaseDir}\*.json"; DestDir: "{app}"; Flags: ignoreversion restartreplace uninsrestartdelete; Attribs: hidden
Source: "{#ReleaseDir}\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs restartreplace uninsrestartdelete; Attribs: hidden

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExeName}"; WorkingDir: "{app}"
Name: "{group}\Uninstall {#AppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExeName}"; Description: "{cm:LaunchProgram,{#AppName}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: files; Name: "{app}\Vic3ModLauncher-Setup.exe"
Type: files; Name: "{app}\Vic3ModLauncher-Uninstall.exe"
