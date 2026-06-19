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
using Microsoft.Win32;

static class Program
{
    [STAThread]
    static int Main(string[] args)
    {
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);

        var requestedAction = args.Length == 0 ? "" : args[0].ToLowerInvariant();
        var removeSettings = Array.Exists(args, item => item.Equals("--remove-settings", StringComparison.OrdinalIgnoreCase));
        Application.Run(new InstallerForm(requestedAction, removeSettings));
        return 0;
    }
}

sealed class InstallerForm : Form
{
    const string AppName = "Victoria 3 Mod Launcher";
    const string AppFolderName = "Vic3ModLauncher";
    const string AppExeName = "vic3_mod_launcher.exe";
    const string SetupExeName = "Vic3ModLauncher-Setup.exe";
    const string RegistryPath = @"Software\Microsoft\Windows\CurrentVersion\Uninstall\Vic3ModLauncher";

    readonly string requestedAction;
    readonly Label statusLabel = new();
    readonly CheckBox removeSettingsBox = new();
    readonly Button installButton = new();
    readonly Button reinstallButton = new();
    readonly Button uninstallButton = new();
    readonly Button closeButton = new();

    public InstallerForm(string requestedAction, bool removeSettings)
    {
        this.requestedAction = requestedAction;

        Text = AppName + " Setup";
        Width = 520;
        Height = 310;
        MinimizeBox = false;
        MaximizeBox = false;
        FormBorderStyle = FormBorderStyle.FixedDialog;
        StartPosition = FormStartPosition.CenterScreen;

        var title = new Label
        {
            Text = AppName,
            Left = 24,
            Top = 20,
            Width = 450,
            Height = 28,
            Font = new System.Drawing.Font(Font.FontFamily, 14, System.Drawing.FontStyle.Bold)
        };

        statusLabel.Left = 24;
        statusLabel.Top = 58;
        statusLabel.Width = 450;
        statusLabel.Height = 54;

        installButton.Text = "Install";
        installButton.Left = 24;
        installButton.Top = 126;
        installButton.Width = 140;
        installButton.Height = 38;
        installButton.Click += (_, _) => RunAction("install", false);

        reinstallButton.Text = "Reinstall / Update";
        reinstallButton.Left = 180;
        reinstallButton.Top = 126;
        reinstallButton.Width = 140;
        reinstallButton.Height = 38;
        reinstallButton.Click += (_, _) => RunAction("reinstall", false);

        uninstallButton.Text = "Uninstall";
        uninstallButton.Left = 336;
        uninstallButton.Top = 126;
        uninstallButton.Width = 140;
        uninstallButton.Height = 38;
        uninstallButton.Click += (_, _) => RunAction("uninstall", removeSettingsBox.Checked);

        removeSettingsBox.Text = "Remove launcher settings and saved playsets";
        removeSettingsBox.Left = 24;
        removeSettingsBox.Top = 182;
        removeSettingsBox.Width = 360;
        removeSettingsBox.Height = 24;
        removeSettingsBox.Checked = removeSettings;

        closeButton.Text = "Close";
        closeButton.Left = 336;
        closeButton.Top = 222;
        closeButton.Width = 140;
        closeButton.Height = 34;
        closeButton.Click += (_, _) => Close();

        Controls.AddRange(new Control[] {
            title,
            statusLabel,
            installButton,
            reinstallButton,
            uninstallButton,
            removeSettingsBox,
            closeButton
        });

        RefreshStatus();
    }

    protected override void OnShown(EventArgs e)
    {
        base.OnShown(e);
        if (requestedAction is "--install" or "install") RunAction("install", false);
        if (requestedAction is "--reinstall" or "reinstall") RunAction("reinstall", removeSettingsBox.Checked);
        if (requestedAction is "--uninstall" or "uninstall") RunAction("uninstall", removeSettingsBox.Checked);
    }

    void RefreshStatus()
    {
        var installed = File.Exists(AppExePath);
        statusLabel.Text = installed
            ? "Installed at:\r\n" + InstallDir
            : "Not installed yet.\r\nTarget folder: " + InstallDir;
        installButton.Enabled = !installed;
        reinstallButton.Enabled = installed;
        uninstallButton.Enabled = installed;
    }

    void RunAction(string action, bool removeSettings)
    {
        try
        {
            SetBusy(true);
            if ((action == "reinstall" || action == "uninstall") && RunningFromInstallDir)
            {
                RelaunchFromTemp(action, removeSettings);
                Close();
                return;
            }

            switch (action)
            {
                case "install":
                    Install(cleanFirst: false);
                    MessageBox.Show("Installed successfully.", AppName, MessageBoxButtons.OK, MessageBoxIcon.Information);
                    break;
                case "reinstall":
                    Install(cleanFirst: true);
                    MessageBox.Show("Reinstalled successfully.", AppName, MessageBoxButtons.OK, MessageBoxIcon.Information);
                    break;
                case "uninstall":
                    if (MessageBox.Show(
                            "Uninstall " + AppName + "?",
                            AppName,
                            MessageBoxButtons.YesNo,
                            MessageBoxIcon.Question) != DialogResult.Yes)
                    {
                        return;
                    }
                    Uninstall(removeSettings);
                    MessageBox.Show("Uninstalled successfully.", AppName, MessageBoxButtons.OK, MessageBoxIcon.Information);
                    break;
            }
        }
        catch (Exception ex)
        {
            MessageBox.Show(ex.ToString(), "Setup failed", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
        finally
        {
            SetBusy(false);
            RefreshStatus();
        }
    }

    void Install(bool cleanFirst)
    {
        StopRunningLauncher();
        if (cleanFirst && Directory.Exists(InstallDir)) DeleteDirectory(InstallDir);
        Directory.CreateDirectory(InstallDir);

        var tempZip = Path.Combine(Path.GetTempPath(), "Vic3ModLauncher-portable.zip");
        using (var source = Assembly.GetExecutingAssembly().GetManifestResourceStream("payload.zip"))
        {
            if (source == null) throw new InvalidOperationException("Installer payload is missing.");
            using var target = File.Create(tempZip);
            source.CopyTo(target);
        }

        ZipFile.ExtractToDirectory(tempZip, InstallDir, true);
        CopySetupIntoInstallDir();
        CreateShortcut(AppShortcutPath, AppExePath, InstallDir, AppExePath);
        CreateShortcut(UninstallShortcutPath, InstalledSetupPath, InstallDir, InstalledSetupPath, "--uninstall");
        RegisterUninstallEntry();
    }

    void Uninstall(bool removeSettings)
    {
        StopRunningLauncher();
        DeleteFile(AppShortcutPath);
        DeleteFile(UninstallShortcutPath);
        Registry.CurrentUser.DeleteSubKeyTree(RegistryPath, throwOnMissingSubKey: false);
        if (Directory.Exists(InstallDir)) DeleteDirectory(InstallDir);
        if (removeSettings && Directory.Exists(ConfigDir)) DeleteDirectory(ConfigDir);
    }

    void StopRunningLauncher()
    {
        foreach (var process in Process.GetProcessesByName(Path.GetFileNameWithoutExtension(AppExeName)))
        {
            try
            {
                process.CloseMainWindow();
                if (!process.WaitForExit(3000)) process.Kill(true);
            }
            catch
            {
                // The installer continues; file operations below will report a useful error if needed.
            }
        }
    }

    void CopySetupIntoInstallDir()
    {
        var current = Application.ExecutablePath;
        if (string.Equals(current, InstalledSetupPath, StringComparison.OrdinalIgnoreCase)) return;
        File.Copy(current, InstalledSetupPath, overwrite: true);
    }

    void RegisterUninstallEntry()
    {
        using var key = Registry.CurrentUser.CreateSubKey(RegistryPath);
        if (key == null) return;
        key.SetValue("DisplayName", AppName);
        key.SetValue("DisplayVersion", "1.0.0");
        key.SetValue("Publisher", "badaruddinl");
        key.SetValue("InstallLocation", InstallDir);
        key.SetValue("DisplayIcon", AppExePath);
        key.SetValue("UninstallString", Quote(InstalledSetupPath) + " --uninstall");
        key.SetValue("QuietUninstallString", Quote(InstalledSetupPath) + " --uninstall");
        key.SetValue("NoModify", 1, RegistryValueKind.DWord);
        key.SetValue("NoRepair", 1, RegistryValueKind.DWord);
    }

    void CreateShortcut(string shortcutPath, string targetPath, string workingDirectory, string iconPath, string arguments = "")
    {
        var ps = "$s=(New-Object -ComObject WScript.Shell).CreateShortcut($env:VIC3_SHORTCUT);" +
                 "$s.TargetPath=$env:VIC3_TARGET;$s.Arguments=$env:VIC3_ARGS;" +
                 "$s.WorkingDirectory=$env:VIC3_DIR;$s.IconLocation=$env:VIC3_ICON;$s.Save()";
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
        startInfo.Environment["VIC3_TARGET"] = targetPath;
        startInfo.Environment["VIC3_ARGS"] = arguments;
        startInfo.Environment["VIC3_DIR"] = workingDirectory;
        startInfo.Environment["VIC3_ICON"] = iconPath;
        using var process = Process.Start(startInfo);
        process?.WaitForExit();
    }

    void RelaunchFromTemp(string action, bool removeSettings)
    {
        var tempSetup = Path.Combine(Path.GetTempPath(), "Vic3ModLauncher-Setup-" + Guid.NewGuid().ToString("N") + ".exe");
        File.Copy(Application.ExecutablePath, tempSetup, overwrite: true);
        var startInfo = new ProcessStartInfo
        {
            FileName = tempSetup,
            UseShellExecute = true
        };
        startInfo.ArgumentList.Add("--" + action);
        if (removeSettings) startInfo.ArgumentList.Add("--remove-settings");
        Process.Start(startInfo);
    }

    void SetBusy(bool busy)
    {
        Cursor = busy ? Cursors.WaitCursor : Cursors.Default;
        installButton.Enabled = !busy;
        reinstallButton.Enabled = !busy;
        uninstallButton.Enabled = !busy;
        closeButton.Enabled = !busy;
        removeSettingsBox.Enabled = !busy;
    }

    static void DeleteDirectory(string path)
    {
        foreach (var item in Directory.EnumerateFileSystemEntries(path, "*", SearchOption.AllDirectories))
        {
            try { File.SetAttributes(item, FileAttributes.Normal); } catch { }
        }
        Directory.Delete(path, recursive: true);
    }

    static void DeleteFile(string path)
    {
        if (File.Exists(path)) File.Delete(path);
    }

    static string Quote(string value)
    {
        return "\"" + value + "\"";
    }

    string InstallDir => Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
        AppFolderName);

    string ConfigDir => Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
        AppFolderName);

    string DesktopDir => Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory);

    string AppExePath => Path.Combine(InstallDir, AppExeName);
    string InstalledSetupPath => Path.Combine(InstallDir, SetupExeName);
    string AppShortcutPath => Path.Combine(DesktopDir, AppName + ".lnk");
    string UninstallShortcutPath => Path.Combine(DesktopDir, "Uninstall " + AppName + ".lnk");

    bool RunningFromInstallDir
    {
        get
        {
            var current = Path.GetFullPath(Application.ExecutablePath);
            var install = Path.GetFullPath(InstallDir).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            return current.StartsWith(install, StringComparison.OrdinalIgnoreCase);
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
