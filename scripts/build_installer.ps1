$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$distDir = Join-Path $root "dist"
$zipPath = Join-Path $distDir "Vic3ModLauncher-portable.zip"
$installerPath = Join-Path $distDir "Vic3ModLauncher-Setup.exe"
$payloadDir = Join-Path $root "build\installer_payload"
$projectDir = Join-Path $root "build\installer_dotnet"

Set-Location $root

function Assert-ChildPath {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][string]$Parent
  )

  $fullPath = [System.IO.Path]::GetFullPath($Path)
  $fullParent = [System.IO.Path]::GetFullPath($Parent).TrimEnd('\') + '\'
  if (-not $fullPath.StartsWith($fullParent, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to modify path outside workspace: $fullPath"
  }
}

Assert-ChildPath -Path $payloadDir -Parent $root
Assert-ChildPath -Path $projectDir -Parent $root

powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "build_release.ps1")

if (-not (Test-Path -LiteralPath $zipPath)) {
  throw "Portable ZIP was not created: $zipPath"
}

if (Test-Path -LiteralPath $payloadDir) {
  Remove-Item -LiteralPath $payloadDir -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $payloadDir | Out-Null
Copy-Item -LiteralPath $zipPath -Destination (Join-Path $payloadDir "Vic3ModLauncher-portable.zip") -Force

$installPs1 = @'
$ErrorActionPreference = "Stop"

$zip = Join-Path $PSScriptRoot "Vic3ModLauncher-portable.zip"
$installDir = Join-Path $env:LOCALAPPDATA "Vic3ModLauncher"

New-Item -ItemType Directory -Force -Path $installDir | Out-Null
Expand-Archive -LiteralPath $zip -DestinationPath $installDir -Force

$desktop = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktop "Victoria 3 Mod Launcher.lnk"
$exePath = Join-Path $installDir "vic3_mod_launcher.exe"
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $exePath
$shortcut.WorkingDirectory = $installDir
$shortcut.IconLocation = $exePath
$shortcut.Save()
'@
$installPs1 | Set-Content -LiteralPath (Join-Path $payloadDir "install_from_package.ps1") -Encoding UTF8

$installCmd = @'
@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install_from_package.ps1"
'@
$installCmd | Set-Content -LiteralPath (Join-Path $payloadDir "install.cmd") -Encoding ASCII

if (Test-Path -LiteralPath $projectDir) {
  Remove-Item -LiteralPath $projectDir -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $projectDir | Out-Null
Copy-Item -LiteralPath (Join-Path $payloadDir "Vic3ModLauncher-portable.zip") -Destination (Join-Path $projectDir "Vic3ModLauncher-portable.zip") -Force
Copy-Item -LiteralPath (Join-Path $root "windows\runner\resources\app_icon.ico") -Destination (Join-Path $projectDir "app_icon.ico") -Force

$csproj = @'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>WinExe</OutputType>
    <TargetFramework>net9.0-windows</TargetFramework>
    <RuntimeIdentifier>win-x64</RuntimeIdentifier>
    <SelfContained>true</SelfContained>
    <PublishSingleFile>true</PublishSingleFile>
    <EnableCompressionInSingleFile>true</EnableCompressionInSingleFile>
    <UseWindowsForms>true</UseWindowsForms>
    <ApplicationIcon>app_icon.ico</ApplicationIcon>
    <AssemblyName>Vic3ModLauncher-Setup</AssemblyName>
  </PropertyGroup>
  <ItemGroup>
    <EmbeddedResource Include="Vic3ModLauncher-portable.zip" LogicalName="payload.zip" />
  </ItemGroup>
</Project>
'@
$csproj | Set-Content -LiteralPath (Join-Path $projectDir "Vic3ModLauncherSetup.csproj") -Encoding UTF8

$program = @'
using System;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Reflection;
using System.Windows.Forms;

static class Program
{
    [STAThread]
    static int Main()
    {
        try
        {
            var installDir = Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                "Vic3ModLauncher");
            Directory.CreateDirectory(installDir);

            var tempZip = Path.Combine(Path.GetTempPath(), "Vic3ModLauncher-portable.zip");
            using (var source = Assembly.GetExecutingAssembly().GetManifestResourceStream("payload.zip"))
            {
                if (source == null) throw new InvalidOperationException("Installer payload is missing.");
                using var target = File.Create(tempZip);
                source.CopyTo(target);
            }

            ZipFile.ExtractToDirectory(tempZip, installDir, true);

            var exePath = Path.Combine(installDir, "vic3_mod_launcher.exe");
            var desktop = Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory);
            var shortcutPath = Path.Combine(desktop, "Victoria 3 Mod Launcher.lnk");
            var ps = "$s=(New-Object -ComObject WScript.Shell).CreateShortcut($env:VIC3_SHORTCUT);" +
                     "$s.TargetPath=$env:VIC3_EXE;$s.WorkingDirectory=$env:VIC3_DIR;" +
                     "$s.IconLocation=$env:VIC3_EXE;$s.Save()";
            var startInfo = new ProcessStartInfo
            {
                FileName = "powershell",
                UseShellExecute = false,
                CreateNoWindow = true
            };
            startInfo.ArgumentList.Add("-NoProfile");
            startInfo.ArgumentList.Add("-ExecutionPolicy");
            startInfo.ArgumentList.Add("Bypass");
            startInfo.ArgumentList.Add("-Command");
            startInfo.ArgumentList.Add(ps);
            startInfo.Environment["VIC3_SHORTCUT"] = shortcutPath;
            startInfo.Environment["VIC3_EXE"] = exePath;
            startInfo.Environment["VIC3_DIR"] = installDir;
            using var process = Process.Start(startInfo);
            process?.WaitForExit();

            MessageBox.Show(
                "Victoria 3 Mod Launcher installed.",
                "Victoria 3 Mod Launcher",
                MessageBoxButtons.OK,
                MessageBoxIcon.Information);
            return 0;
        }
        catch (Exception ex)
        {
            MessageBox.Show(ex.ToString(), "Install failed", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return 1;
        }
    }
}
'@
$program | Set-Content -LiteralPath (Join-Path $projectDir "Program.cs") -Encoding UTF8

dotnet publish (Join-Path $projectDir "Vic3ModLauncherSetup.csproj") -c Release -o (Join-Path $projectDir "publish")

$builtInstaller = Join-Path $projectDir "publish\Vic3ModLauncher-Setup.exe"
if (-not (Test-Path -LiteralPath $builtInstaller)) {
  throw "Installer was not created: $builtInstaller"
}

if (Test-Path -LiteralPath $installerPath) {
  Remove-Item -LiteralPath $installerPath -Force
}
Copy-Item -LiteralPath $builtInstaller -Destination $installerPath -Force
Write-Host "Installer: $installerPath"
