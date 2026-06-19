$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$releaseDir = Join-Path $root "build\windows\x64\runner\Release"
$distDir = Join-Path $root "dist"
$zipPath = Join-Path $distDir "Vic3ModLauncher-portable.zip"

Set-Location $root
flutter pub get
flutter build windows --release

New-Item -ItemType Directory -Force -Path $distDir | Out-Null
if (Test-Path -LiteralPath $zipPath) {
  Remove-Item -LiteralPath $zipPath -Force
}

Compress-Archive -Path (Join-Path $releaseDir "*") -DestinationPath $zipPath -Force
Write-Host "Release: $releaseDir"
Write-Host "Portable ZIP: $zipPath"
