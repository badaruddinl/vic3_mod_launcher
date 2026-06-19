$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$releaseDir = Join-Path $root "build\windows\x64\runner\Release"
$exe = Join-Path $releaseDir "vic3_mod_launcher.exe"

if (-not (Test-Path -LiteralPath $exe)) {
  Set-Location $root
  flutter pub get
  flutter build windows --release
}

$installDir = Join-Path $env:LOCALAPPDATA "Vic3ModLauncher"
New-Item -ItemType Directory -Force -Path $installDir | Out-Null
Copy-Item -Path (Join-Path $releaseDir "*") -Destination $installDir -Recurse -Force

$desktop = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktop "Victoria 3 Mod Launcher.lnk"
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = Join-Path $installDir "vic3_mod_launcher.exe"
$shortcut.WorkingDirectory = $installDir
$shortcut.IconLocation = $shortcut.TargetPath
$shortcut.Save()

Write-Host "Installed to: $installDir"
Write-Host "Shortcut: $shortcutPath"
