$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$releaseDir = Join-Path $root "build\windows\x64\runner\Release"
$distDir = Join-Path $root "dist"
$installerScript = Join-Path $root "installer\vic3_mod_launcher.iss"
$iconFile = Join-Path $root "windows\runner\resources\app_icon.ico"
$installerPath = Join-Path $distDir "Vic3ModLauncher-Setup.exe"

function Find-InnoCompiler {
  $command = Get-Command ISCC.exe -ErrorAction SilentlyContinue
  if ($command) {
    return $command.Source
  }

  $candidates = @(
    "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe",
    "$env:ProgramFiles\Inno Setup 6\ISCC.exe",
    "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe"
  )

  foreach ($candidate in $candidates) {
    if (Test-Path -LiteralPath $candidate) {
      return $candidate
    }
  }

  throw @"
Inno Setup compiler was not found.

Install it first:
  winget install --id JRSoftware.InnoSetup -e

Then run:
  .\scripts\build_installer.ps1
"@
}

function Get-AppVersion {
  $pubspec = Get-Content -LiteralPath (Join-Path $root "pubspec.yaml")
  $line = $pubspec | Where-Object { $_ -match "^\s*version:\s*(.+)\s*$" } | Select-Object -First 1
  if (-not $line) {
    return @{
      Display = "1.0.0"
      File = "1.0.0.0"
    }
  }

  $raw = ($line -replace "^\s*version:\s*", "").Trim()
  $parts = $raw -split "\+", 2
  $display = $parts[0]
  $build = if ($parts.Count -gt 1 -and $parts[1] -match "^\d+$") { $parts[1] } else { "0" }
  return @{
    Display = $display
    File = "$display.$build"
  }
}

function Remove-ExistingInstaller {
  if (-not (Test-Path -LiteralPath $installerPath)) {
    return
  }

  for ($attempt = 0; $attempt -lt 5; $attempt++) {
    try {
      Remove-Item -LiteralPath $installerPath -Force
      return
    } catch {
      if ($attempt -eq 4) {
        throw
      }
      Start-Sleep -Milliseconds 500
    }
  }
}

$iscc = Find-InnoCompiler
$version = Get-AppVersion

Set-Location $root
powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "build_release.ps1")

$launcherExe = Join-Path $releaseDir "vic3_mod_launcher.exe"
if (-not (Test-Path -LiteralPath $launcherExe)) {
  throw "Release executable was not created: $launcherExe"
}

if (-not (Test-Path -LiteralPath $installerScript)) {
  throw "Installer script was not found: $installerScript"
}

New-Item -ItemType Directory -Force -Path $distDir | Out-Null
Remove-ExistingInstaller

& $iscc `
  "/DAppVersion=""$($version.Display)""" `
  "/DAppFileVersion=""$($version.File)""" `
  "/DReleaseDir=""$releaseDir""" `
  "/DOutputDir=""$distDir""" `
  "/DIconFile=""$iconFile""" `
  $installerScript

if ($LASTEXITCODE -ne 0) {
  throw "Inno Setup failed with exit code $LASTEXITCODE"
}

if (-not (Test-Path -LiteralPath $installerPath)) {
  throw "Installer was not created: $installerPath"
}

Write-Host "Installer: $installerPath"
