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
using System.Security.Principal;
using System.Windows.Forms;
using Microsoft.Win32;

static class Program
{
    [STAThread]
    static int Main(string[] args)
    {
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);

        Application.Run(new InstallerForm(SetupOptions.Parse(args)));
        return 0;
    }
}

sealed class SetupOptions
{
    public string Action { get; set; } = "";
    public string InstallDir { get; set; } = "";
    public bool RemoveSettings { get; set; }
    public bool CreateDesktopShortcut { get; set; } = true;
    public bool AutoRun { get; set; }

    public static SetupOptions Parse(string[] args)
    {
        var options = new SetupOptions();
        for (var i = 0; i < args.Length; i++)
        {
            var item = args[i].ToLowerInvariant();
            if (item is "--install" or "install") options.Action = "install";
            else if (item is "--reinstall" or "reinstall") options.Action = "reinstall";
            else if (item is "--uninstall" or "uninstall") options.Action = "uninstall";
            else if (item == "--dir" && i + 1 < args.Length) options.InstallDir = args[++i];
            else if (item == "--remove-settings") options.RemoveSettings = true;
            else if (item == "--no-desktop-shortcut") options.CreateDesktopShortcut = false;
            else if (item == "--auto-run") options.AutoRun = true;
        }
        var currentName = Path.GetFileNameWithoutExtension(Application.ExecutablePath);
        if (string.IsNullOrWhiteSpace(options.Action) &&
            currentName.Contains("uninstall", StringComparison.OrdinalIgnoreCase))
        {
            options.Action = "uninstall";
        }
        return options;
    }
}

sealed class InstallerForm : Form
{
    const string AppName = "Victoria 3 Mod Launcher";
    const string AppExeName = "vic3_mod_launcher.exe";
    const string SetupExeName = "Vic3ModLauncher-Setup.exe";
    const string UninstallerExeName = "Vic3ModLauncher-Uninstall.exe";
    const string RegistryPath = @"Software\Microsoft\Windows\CurrentVersion\Uninstall\Vic3ModLauncher";

    readonly SetupOptions options;
    readonly Panel page = new();
    readonly Label headerLabel = new();
    readonly Label bodyLabel = new();
    readonly Button backButton = new();
    readonly Button nextButton = new();
    readonly Button cancelButton = new();
    readonly RadioButton installRadio = new();
    readonly RadioButton reinstallRadio = new();
    readonly RadioButton uninstallRadio = new();
    readonly TextBox installDirBox = new();
    readonly CheckBox desktopShortcutBox = new();
    readonly CheckBox removeSettingsBox = new();
    readonly ProgressBar progressBar = new();
    readonly Label progressLabel = new();

    int step;
    string action = "install";
    string installDir = "";
    bool installFound;
    bool completed;

    public InstallerForm(SetupOptions options)
    {
        this.options = options;
        installDir = string.IsNullOrWhiteSpace(options.InstallDir)
            ? FindInstallDirOrDefault()
            : options.InstallDir;
        installFound = !string.IsNullOrWhiteSpace(FindInstalledDir());
        action = string.IsNullOrWhiteSpace(options.Action)
            ? (installFound ? "reinstall" : "install")
            : options.Action;
        if (action == "uninstall" && !string.IsNullOrWhiteSpace(options.Action))
        {
            step = 2;
        }

        Text = AppName + " Setup";
        Width = 680;
        Height = 470;
        MinimizeBox = false;
        MaximizeBox = false;
        FormBorderStyle = FormBorderStyle.FixedDialog;
        StartPosition = FormStartPosition.CenterScreen;

        headerLabel.Left = 24;
        headerLabel.Top = 20;
        headerLabel.Width = 610;
        headerLabel.Height = 28;
        headerLabel.Font = new System.Drawing.Font(Font.FontFamily, 15, System.Drawing.FontStyle.Bold);

        bodyLabel.Left = 24;
        bodyLabel.Top = 58;
        bodyLabel.Width = 610;
        bodyLabel.Height = 44;

        page.Left = 24;
        page.Top = 112;
        page.Width = 610;
        page.Height = 260;

        backButton.Text = "Back";
        backButton.Left = 292;
        backButton.Top = 386;
        backButton.Width = 100;
        backButton.Height = 34;
        backButton.Click += (_, _) => MoveBack();

        nextButton.Text = "Next";
        nextButton.Left = 404;
        nextButton.Top = 386;
        nextButton.Width = 100;
        nextButton.Height = 34;
        nextButton.Click += (_, _) => MoveNext();

        cancelButton.Text = "Cancel";
        cancelButton.Left = 516;
        cancelButton.Top = 386;
        cancelButton.Width = 100;
        cancelButton.Height = 34;
        cancelButton.Click += (_, _) => Close();

        Controls.AddRange(new Control[] { headerLabel, bodyLabel, page, backButton, nextButton, cancelButton });
        Render();
    }

    protected override void OnShown(EventArgs e)
    {
        base.OnShown(e);
        if (options.AutoRun && !string.IsNullOrWhiteSpace(options.Action))
        {
            BeginInvoke(new Action(() => ExecuteAction()));
        }
    }

    void Render()
    {
        page.Controls.Clear();
        backButton.Enabled = step > 0;
        cancelButton.Text = "Cancel";

        if (step == 0)
        {
            RenderWelcome();
        }
        else if (step == 1 && action != "uninstall")
        {
            RenderInstallFolder();
        }
        else
        {
            RenderReady();
        }
    }

    void RenderWelcome()
    {
        var installedDir = FindInstalledDir();
        installFound = !string.IsNullOrWhiteSpace(installedDir);
        if (installFound) installDir = installedDir;

        headerLabel.Text = installFound ? "Maintenance" : "Welcome to " + AppName + " Setup";
        bodyLabel.Text = installFound
            ? "Setup found an existing installation. Choose whether to update or remove it."
            : "Setup will install the launcher as a normal Windows application.";
        nextButton.Text = "Next";

        var installedText = string.IsNullOrWhiteSpace(installedDir)
            ? "No existing installation was found."
            : "Existing installation:\r\n" + installedDir;

        var status = new Label
        {
            Text = installedText,
            Left = 4,
            Top = 0,
            Width = 580,
            Height = 48
        };

        if (!installFound)
        {
            action = "install";
            var note = new Label
            {
                Text = "Click Next to choose the installation folder.",
                Left = 4,
                Top = 70,
                Width = 580,
                Height = 32
            };
            page.Controls.AddRange(new Control[] { status, note });
            return;
        }

        reinstallRadio.Text = "Reinstall / Update";
        reinstallRadio.Left = 4;
        reinstallRadio.Top = 70;
        reinstallRadio.Width = 240;
        reinstallRadio.Checked = action == "reinstall";
        reinstallRadio.CheckedChanged += (_, _) => { if (reinstallRadio.Checked) action = "reinstall"; };

        uninstallRadio.Text = "Uninstall";
        uninstallRadio.Left = 4;
        uninstallRadio.Top = 104;
        uninstallRadio.Width = 240;
        uninstallRadio.Checked = action == "uninstall";
        uninstallRadio.CheckedChanged += (_, _) => { if (uninstallRadio.Checked) action = "uninstall"; };

        page.Controls.AddRange(new Control[] { status, reinstallRadio, uninstallRadio });
    }

    void RenderInstallFolder()
    {
        headerLabel.Text = action == "install" ? "Choose Install Location" : "Choose Update Location";
        bodyLabel.Text = "Setup will install the launcher into this folder. The default is Program Files.";
        nextButton.Text = "Next";

        var folderLabel = new Label
        {
            Text = "Destination folder:",
            Left = 4,
            Top = 10,
            Width = 180,
            Height = 24
        };

        installDirBox.Left = 4;
        installDirBox.Top = 40;
        installDirBox.Width = 500;
        installDirBox.Height = 24;
        installDirBox.Text = installDir;
        installDirBox.TextChanged += (_, _) => installDir = installDirBox.Text.Trim();

        var browseButton = new Button
        {
            Text = "Browse...",
            Left = 514,
            Top = 38,
            Width = 92,
            Height = 28
        };
        browseButton.Click += (_, _) =>
        {
            using var dialog = new FolderBrowserDialog();
            dialog.Description = "Choose install folder";
            dialog.SelectedPath = Directory.Exists(installDir) ? installDir : DefaultInstallDir();
            if (dialog.ShowDialog(this) == DialogResult.OK)
            {
                installDirBox.Text = dialog.SelectedPath;
            }
        };

        desktopShortcutBox.Text = "Create Desktop shortcut";
        desktopShortcutBox.Left = 4;
        desktopShortcutBox.Top = 88;
        desktopShortcutBox.Width = 260;
        desktopShortcutBox.Height = 24;
        desktopShortcutBox.Checked = options.CreateDesktopShortcut;
        desktopShortcutBox.CheckedChanged += (_, _) => options.CreateDesktopShortcut = desktopShortcutBox.Checked;

        var note = new Label
        {
            Text = "If this folder is inside Program Files, Windows will ask for administrator permission.",
            Left = 4,
            Top = 132,
            Width = 580,
            Height = 42
        };

        page.Controls.AddRange(new Control[] { folderLabel, installDirBox, browseButton, desktopShortcutBox, note });
    }

    void RenderReady()
    {
        var isUninstall = action == "uninstall";
        headerLabel.Text = isUninstall ? "Ready to Uninstall" : "Ready to Install";
        bodyLabel.Text = isUninstall
            ? "Setup is ready to remove the launcher."
            : "Setup is ready to copy files and create shortcuts.";
        nextButton.Text = isUninstall ? "Uninstall" : (action == "reinstall" ? "Reinstall" : "Install");

        var target = isUninstall ? FindInstalledDirOrCurrent() : installDir;
        var summary = new Label
        {
            Text = (isUninstall ? "Remove from:" : "Install to:") + "\r\n" + target,
            Left = 4,
            Top = 0,
            Width = 580,
            Height = 64
        };

        page.Controls.Add(summary);

        if (isUninstall)
        {
            removeSettingsBox.Text = "Remove launcher settings and saved playsets";
            removeSettingsBox.Left = 4;
            removeSettingsBox.Top = 82;
            removeSettingsBox.Width = 360;
            removeSettingsBox.Height = 24;
            removeSettingsBox.Checked = options.RemoveSettings;
            removeSettingsBox.CheckedChanged += (_, _) => options.RemoveSettings = removeSettingsBox.Checked;
            page.Controls.Add(removeSettingsBox);
        }
    }

    void MoveNext()
    {
        if (step == 0)
        {
            if (action == "uninstall")
            {
                step = 2;
            }
            else
            {
                step = 1;
            }
            Render();
            return;
        }

        if (step == 1)
        {
            if (string.IsNullOrWhiteSpace(installDir))
            {
                MessageBox.Show("Choose an install folder first.", AppName, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }
            step = 2;
            Render();
            return;
        }

        ExecuteAction();
    }

    void MoveBack()
    {
        if (step == 2 && action == "uninstall") step = 0;
        else step = Math.Max(0, step - 1);
        Render();
    }

    void ExecuteAction()
    {
        try
        {
            SetBusy(true);

            var targetDir = action == "uninstall" ? FindInstalledDirOrCurrent() : installDir;
            if (string.IsNullOrWhiteSpace(targetDir))
            {
                MessageBox.Show("No installation folder was found.", AppName, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (ShouldRelaunch(action, targetDir))
            {
                Relaunch(action, targetDir, options.RemoveSettings, options.CreateDesktopShortcut);
                Close();
                return;
            }

            switch (action)
            {
                case "install":
                    ShowProgress("Installing");
                    Install(targetDir, cleanFirst: false, options.CreateDesktopShortcut);
                    Complete("Installed successfully.", targetDir);
                    break;
                case "reinstall":
                    ShowProgress("Reinstalling");
                    Install(targetDir, cleanFirst: true, options.CreateDesktopShortcut);
                    Complete("Reinstalled successfully.", targetDir);
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
                    ShowProgress("Uninstalling");
                    Uninstall(targetDir, options.RemoveSettings);
                    Complete("Uninstalled successfully.", targetDir);
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
        }
    }

    void ShowProgress(string title)
    {
        page.Controls.Clear();
        headerLabel.Text = title;
        bodyLabel.Text = "Please wait while setup applies the selected changes.";
        backButton.Enabled = false;
        nextButton.Enabled = false;
        cancelButton.Enabled = false;

        progressLabel.Left = 4;
        progressLabel.Top = 26;
        progressLabel.Width = 580;
        progressLabel.Height = 28;
        progressLabel.Text = "Preparing...";

        progressBar.Left = 4;
        progressBar.Top = 66;
        progressBar.Width = 580;
        progressBar.Height = 24;
        progressBar.Minimum = 0;
        progressBar.Maximum = 100;
        progressBar.Value = 0;
        progressBar.Style = ProgressBarStyle.Continuous;

        page.Controls.AddRange(new Control[] { progressLabel, progressBar });
        Application.DoEvents();
    }

    void ReportProgress(int value, string message)
    {
        progressBar.Value = Math.Max(progressBar.Minimum, Math.Min(progressBar.Maximum, value));
        progressLabel.Text = message;
        Application.DoEvents();
    }

    void Complete(string message, string targetDir)
    {
        completed = true;
        ShowFinished(message, targetDir);
    }

    void ShowFinished(string message, string targetDir)
    {
        page.Controls.Clear();
        headerLabel.Text = "Setup Complete";
        bodyLabel.Text = message;
        backButton.Enabled = false;
        nextButton.Enabled = false;
        cancelButton.Text = "Finish";

        var label = new Label
        {
            Text = "Location:\r\n" + targetDir,
            Left = 4,
            Top = 0,
            Width = 580,
            Height = 64
        };
        page.Controls.Add(label);

        if (action != "uninstall" && File.Exists(Path.Combine(targetDir, AppExeName)))
        {
            var launchButton = new Button
            {
                Text = "Launch",
                Left = 4,
                Top = 84,
                Width = 120,
                Height = 34
            };
            launchButton.Click += (_, _) => Process.Start(new ProcessStartInfo
            {
                FileName = Path.Combine(targetDir, AppExeName),
                WorkingDirectory = targetDir,
                UseShellExecute = true
            });
            page.Controls.Add(launchButton);
        }
    }

    void Install(string targetDir, bool cleanFirst, bool createDesktopShortcut)
    {
        ReportProgress(8, "Closing running launcher...");
        StopRunningLauncher();
        if (cleanFirst && Directory.Exists(targetDir))
        {
            ReportProgress(18, "Removing previous installation...");
            StopProcessesFromDirectory(targetDir);
            DeleteDirectory(targetDir);
        }
        ReportProgress(28, "Creating install folder...");
        Directory.CreateDirectory(targetDir);

        ReportProgress(38, "Preparing package...");
        var tempZip = Path.Combine(Path.GetTempPath(), "Vic3ModLauncher-portable.zip");
        using (var source = Assembly.GetExecutingAssembly().GetManifestResourceStream("payload.zip"))
        {
            if (source == null) throw new InvalidOperationException("Installer payload is missing.");
            using var target = File.Create(tempZip);
            source.CopyTo(target);
        }

        ReportProgress(55, "Extracting application files...");
        ZipFile.ExtractToDirectory(tempZip, targetDir, true);
        ReportProgress(72, "Installing maintenance tools...");
        CopyMaintenanceTools(targetDir);
        ReportProgress(84, "Creating shortcuts...");
        if (createDesktopShortcut) CreateShortcut(DesktopShortcutPath, AppExePath(targetDir), targetDir, AppExePath(targetDir));
        CreateStartMenuShortcuts(targetDir);
        ReportProgress(94, "Registering Windows uninstall entry...");
        RegisterUninstallEntry(targetDir);
        ReportProgress(100, "Done.");
    }

    void Uninstall(string targetDir, bool removeSettings)
    {
        ReportProgress(10, "Closing running launcher...");
        StopRunningLauncher();
        ReportProgress(25, "Removing shortcuts...");
        DeleteFile(DesktopShortcutPath);
        DeleteStartMenuShortcuts();
        ReportProgress(40, "Removing Windows uninstall entry...");
        DeleteRegistryEntries();
        ReportProgress(62, "Removing application files...");
        if (Directory.Exists(targetDir))
        {
            StopProcessesFromDirectory(targetDir);
            DeleteDirectory(targetDir);
        }
        if (removeSettings && Directory.Exists(ConfigDir))
        {
            ReportProgress(84, "Removing settings and saved playsets...");
            DeleteDirectory(ConfigDir);
        }
        ReportProgress(100, "Done.");
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

    void StopProcessesFromDirectory(string targetDir)
    {
        var currentId = Environment.ProcessId;
        var target = Path.GetFullPath(targetDir).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
        foreach (var process in Process.GetProcesses())
        {
            try
            {
                if (process.Id == currentId) continue;
                var path = process.MainModule?.FileName;
                if (string.IsNullOrWhiteSpace(path)) continue;
                var fullPath = Path.GetFullPath(path);
                if (!fullPath.StartsWith(target, StringComparison.OrdinalIgnoreCase)) continue;

                process.CloseMainWindow();
                if (!process.WaitForExit(3000)) process.Kill(true);
                process.WaitForExit(5000);
            }
            catch
            {
                // Some system processes do not expose MainModule. Ignore them.
            }
        }
    }

    void CopyMaintenanceTools(string targetDir)
    {
        var current = Application.ExecutablePath;
        var installedSetup = InstalledSetupPath(targetDir);
        var installedUninstaller = UninstallerPath(targetDir);
        if (!string.Equals(current, installedSetup, StringComparison.OrdinalIgnoreCase))
        {
            File.Copy(current, installedSetup, overwrite: true);
        }
        if (!string.Equals(current, installedUninstaller, StringComparison.OrdinalIgnoreCase))
        {
            File.Copy(current, installedUninstaller, overwrite: true);
        }
    }

    void RegisterUninstallEntry(string targetDir)
    {
        using var key = (IsAdministrator() ? Registry.LocalMachine : Registry.CurrentUser).CreateSubKey(RegistryPath);
        if (key == null) return;
        key.SetValue("DisplayName", AppName);
        key.SetValue("DisplayVersion", "1.0.0");
        key.SetValue("Publisher", "badaruddinl");
        key.SetValue("InstallLocation", targetDir);
        key.SetValue("DisplayIcon", AppExePath(targetDir));
        key.SetValue("UninstallString", Quote(UninstallerPath(targetDir)) + " --uninstall --dir " + Quote(targetDir));
        key.SetValue("QuietUninstallString", Quote(UninstallerPath(targetDir)) + " --uninstall --dir " + Quote(targetDir));
        key.SetValue("NoModify", 1, RegistryValueKind.DWord);
        key.SetValue("NoRepair", 1, RegistryValueKind.DWord);
    }

    void DeleteRegistryEntries()
    {
        Registry.CurrentUser.DeleteSubKeyTree(RegistryPath, throwOnMissingSubKey: false);
        if (IsAdministrator())
        {
            Registry.LocalMachine.DeleteSubKeyTree(RegistryPath, throwOnMissingSubKey: false);
        }
    }

    void CreateStartMenuShortcuts(string targetDir)
    {
        Directory.CreateDirectory(StartMenuDir);
        CreateShortcut(Path.Combine(StartMenuDir, AppName + ".lnk"), AppExePath(targetDir), targetDir, AppExePath(targetDir));
        CreateShortcut(
            Path.Combine(StartMenuDir, "Uninstall " + AppName + ".lnk"),
            UninstallerPath(targetDir),
            targetDir,
            UninstallerPath(targetDir),
            "--uninstall --dir " + Quote(targetDir));
    }

    void DeleteStartMenuShortcuts()
    {
        if (Directory.Exists(StartMenuDir)) DeleteDirectory(StartMenuDir);
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

    bool ShouldRelaunch(string selectedAction, string targetDir)
    {
        if ((selectedAction == "reinstall" || selectedAction == "uninstall") && RunningFromDirectory(targetDir)) return true;
        return RequiresAdmin(targetDir) && !IsAdministrator();
    }

    void Relaunch(string selectedAction, string targetDir, bool removeSettings, bool createDesktopShortcut)
    {
        var executable = Application.ExecutablePath;
        if (selectedAction == "reinstall" || selectedAction == "uninstall")
        {
            var tempSetup = Path.Combine(Path.GetTempPath(), "Vic3ModLauncher-Setup-" + Guid.NewGuid().ToString("N") + ".exe");
            File.Copy(Application.ExecutablePath, tempSetup, overwrite: true);
            executable = tempSetup;
        }

        var startInfo = new ProcessStartInfo
        {
            FileName = executable,
            UseShellExecute = true,
            Arguments = "--" + selectedAction + " --auto-run --dir " + Quote(targetDir)
        };
        if (removeSettings) startInfo.Arguments += " --remove-settings";
        if (!createDesktopShortcut) startInfo.Arguments += " --no-desktop-shortcut";
        if (RequiresAdmin(targetDir) && !IsAdministrator()) startInfo.Verb = "runas";
        Process.Start(startInfo);
    }

    void SetBusy(bool busy)
    {
        Cursor = busy ? Cursors.WaitCursor : Cursors.Default;
        if (completed)
        {
            backButton.Enabled = false;
            nextButton.Enabled = false;
            cancelButton.Enabled = true;
            return;
        }
        backButton.Enabled = !busy && step > 0;
        nextButton.Enabled = !busy;
        cancelButton.Enabled = !busy;
    }

    static void DeleteDirectory(string path)
    {
        for (var attempt = 0; attempt < 12; attempt++)
        {
            try
            {
                foreach (var item in Directory.EnumerateFileSystemEntries(path, "*", SearchOption.AllDirectories))
                {
                    try { File.SetAttributes(item, FileAttributes.Normal); } catch { }
                }
                Directory.Delete(path, recursive: true);
                return;
            }
            catch (IOException) when (attempt < 11)
            {
                System.Threading.Thread.Sleep(500);
            }
            catch (UnauthorizedAccessException) when (attempt < 11)
            {
                System.Threading.Thread.Sleep(500);
            }
        }
    }

    static void DeleteFile(string path)
    {
        if (File.Exists(path)) File.Delete(path);
    }

    static string Quote(string value)
    {
        return "\"" + value + "\"";
    }

    static bool IsAdministrator()
    {
        using var identity = WindowsIdentity.GetCurrent();
        return new WindowsPrincipal(identity).IsInRole(WindowsBuiltInRole.Administrator);
    }

    static string DefaultInstallDir()
    {
        return Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles), AppName);
    }

    static bool RequiresAdmin(string targetDir)
    {
        var full = Path.GetFullPath(targetDir).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
        var programFiles = Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles);
        var programFilesX86 = Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86);
        var windows = Environment.GetFolderPath(Environment.SpecialFolder.Windows);
        return StartsWithPath(full, programFiles) || StartsWithPath(full, programFilesX86) || StartsWithPath(full, windows);
    }

    static bool StartsWithPath(string path, string parent)
    {
        if (string.IsNullOrWhiteSpace(parent)) return false;
        var fullParent = Path.GetFullPath(parent).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
        return path.StartsWith(fullParent, StringComparison.OrdinalIgnoreCase);
    }

    static string ReadInstallDirFromRegistry(RegistryKey root)
    {
        using var key = root.OpenSubKey(RegistryPath);
        return key?.GetValue("InstallLocation")?.ToString() ?? "";
    }

    static string FindInstalledDir()
    {
        var hklm = ReadInstallDirFromRegistry(Registry.LocalMachine);
        if (!string.IsNullOrWhiteSpace(hklm) && File.Exists(Path.Combine(hklm, AppExeName))) return hklm;

        var hkcu = ReadInstallDirFromRegistry(Registry.CurrentUser);
        if (!string.IsNullOrWhiteSpace(hkcu) && File.Exists(Path.Combine(hkcu, AppExeName))) return hkcu;

        var oldLocalAppData = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "Vic3ModLauncher");
        if (File.Exists(Path.Combine(oldLocalAppData, AppExeName))) return oldLocalAppData;

        return "";
    }

    static string FindInstallDirOrDefault()
    {
        var installed = FindInstalledDir();
        return string.IsNullOrWhiteSpace(installed) ? DefaultInstallDir() : installed;
    }

    string FindInstalledDirOrCurrent()
    {
        var installed = FindInstalledDir();
        if (!string.IsNullOrWhiteSpace(installed)) return installed;
        return installDir;
    }

    string ConfigDir => Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
        "Vic3ModLauncher");

    string DesktopDir => Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory);
    string StartMenuDir => Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.Programs),
        AppName);

    string DesktopShortcutPath => Path.Combine(DesktopDir, AppName + ".lnk");
    static string AppExePath(string targetDir) => Path.Combine(targetDir, AppExeName);
    static string InstalledSetupPath(string targetDir) => Path.Combine(targetDir, SetupExeName);
    static string UninstallerPath(string targetDir) => Path.Combine(targetDir, UninstallerExeName);

    bool RunningFromDirectory(string targetDir)
    {
        var current = Path.GetFullPath(Application.ExecutablePath);
        var target = Path.GetFullPath(targetDir).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
        return current.StartsWith(target, StringComparison.OrdinalIgnoreCase);
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
