param(
  [string]$ExePath = "",
  [string]$OutputPath = "",
  [switch]$AllMenus,
  [int]$StartupDelayMs = 2500
)

$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
if ([string]::IsNullOrWhiteSpace($ExePath)) {
  $ExePath = Join-Path $root "build\windows\x64\runner\Release\vic3_mod_launcher.exe"
}
if ([string]::IsNullOrWhiteSpace($OutputPath) -and -not $AllMenus) {
  $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
  $OutputPath = Join-Path $root "artifacts\ui\home-$stamp.png"
}
if ($AllMenus) {
  $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
  $OutputPath = Join-Path $root "artifacts\ui\audit-$stamp"
}
if (-not (Test-Path -LiteralPath $ExePath)) {
  throw "Executable not found: $ExePath. Run flutter build windows --release first."
}

$outputDir = if ($AllMenus) { $OutputPath } else { Split-Path -Parent $OutputPath }
if (-not (Test-Path -LiteralPath $outputDir)) {
  New-Item -ItemType Directory -Path $outputDir | Out-Null
}

Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;
using System.Runtime.InteropServices;

public static class Win32Capture {
  [DllImport("user32.dll")]
  public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

  [DllImport("user32.dll")]
  public static extern bool SetForegroundWindow(IntPtr hWnd);

  [DllImport("user32.dll")]
  public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);

  [DllImport("user32.dll")]
  public static extern bool SetCursorPos(int X, int Y);

  [DllImport("user32.dll")]
  public static extern void mouse_event(uint dwFlags, uint dx, uint dy, uint dwData, UIntPtr dwExtraInfo);

  public struct RECT {
    public int Left;
    public int Top;
    public int Right;
    public int Bottom;
  }
}
"@

$MouseLeftDown = 0x0002
$MouseLeftUp = 0x0004
$HwndTopmost = [IntPtr](-1)
$SwpNoMove = 0x0002
$SwpNoSize = 0x0001
$SwpShowWindow = 0x0040

function Set-WindowOnTop {
  param([IntPtr]$Handle)

  [Win32Capture]::SetWindowPos(
    $Handle,
    $HwndTopmost,
    0,
    0,
    0,
    0,
    $SwpNoMove -bor $SwpNoSize -bor $SwpShowWindow
  ) | Out-Null
  [Win32Capture]::SetForegroundWindow($Handle) | Out-Null
}

function Get-WindowCaptureRect {
  param([IntPtr]$Handle)

  $rect = New-Object Win32Capture+RECT
  if (-not [Win32Capture]::GetWindowRect($Handle, [ref]$rect)) {
    throw "GetWindowRect failed."
  }

  $width = $rect.Right - $rect.Left
  $height = $rect.Bottom - $rect.Top
  if ($width -le 0 -or $height -le 0) {
    throw "Invalid window rectangle: $width x $height."
  }

  return [PSCustomObject]@{
    Left = $rect.Left
    Top = $rect.Top
    Width = $width
    Height = $height
  }
}

function Save-WindowScreenshot {
  param(
    [IntPtr]$Handle,
    [string]$Path
  )

  $captureRect = Get-WindowCaptureRect -Handle $Handle
  Set-WindowOnTop -Handle $Handle
  Start-Sleep -Milliseconds 200
  [Win32Capture]::SetCursorPos(
    $captureRect.Left + [Math]::Floor($captureRect.Width / 2),
    $captureRect.Top + $captureRect.Height - 18
  ) | Out-Null
  Start-Sleep -Milliseconds 700
  $bitmap = New-Object System.Drawing.Bitmap $captureRect.Width, $captureRect.Height
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  try {
    $graphics.CopyFromScreen($captureRect.Left, $captureRect.Top, 0, 0, $bitmap.Size)
    $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
  } finally {
    $graphics.Dispose()
    $bitmap.Dispose()
  }

  return [PSCustomObject]@{
    OutputPath = (Resolve-Path -LiteralPath $Path).Path
    Width = $captureRect.Width
    Height = $captureRect.Height
  }
}

function Invoke-WindowClick {
  param(
    [IntPtr]$Handle,
    [int]$X,
    [int]$Y,
    [int]$DelayMs = 500
  )

  $captureRect = Get-WindowCaptureRect -Handle $Handle
  Set-WindowOnTop -Handle $Handle
  Start-Sleep -Milliseconds 100
  [Win32Capture]::SetCursorPos($captureRect.Left + $X, $captureRect.Top + $Y) | Out-Null
  [Win32Capture]::mouse_event($MouseLeftDown, 0, 0, 0, [UIntPtr]::Zero)
  Start-Sleep -Milliseconds 40
  [Win32Capture]::mouse_event($MouseLeftUp, 0, 0, 0, [UIntPtr]::Zero)
  Start-Sleep -Milliseconds $DelayMs
}

$startedProcess = Start-Process -FilePath $ExePath -PassThru
Start-Sleep -Milliseconds $StartupDelayMs

try {
  $process = Get-Process -Id $startedProcess.Id
  $handle = [IntPtr]::Zero
  for ($i = 0; $i -lt 40; $i++) {
    $process.Refresh()
    if ($process.MainWindowHandle -ne 0) {
      $handle = [IntPtr]$process.MainWindowHandle
      break
    }
    Start-Sleep -Milliseconds 250
  }

  if ($handle -eq [IntPtr]::Zero) {
    throw "Window handle was not found for process $($startedProcess.Id)."
  }

  [Win32Capture]::SetForegroundWindow($handle) | Out-Null
  Start-Sleep -Milliseconds 350

  if ($AllMenus) {
    $captures = New-Object System.Collections.Generic.List[object]
    $captures.Add((Save-WindowScreenshot -Handle $handle -Path (Join-Path $OutputPath "01-home.png")))

    Invoke-WindowClick -Handle $handle -X 50 -Y 48 -DelayMs 900
    $captures.Add((Save-WindowScreenshot -Handle $handle -Path (Join-Path $OutputPath "02-settings-general.png")))

    Invoke-WindowClick -Handle $handle -X 174 -Y 150
    $captures.Add((Save-WindowScreenshot -Handle $handle -Path (Join-Path $OutputPath "03-settings-mods.png")))

    Invoke-WindowClick -Handle $handle -X 263 -Y 150
    $captures.Add((Save-WindowScreenshot -Handle $handle -Path (Join-Path $OutputPath "04-settings-dlc.png")))

    Invoke-WindowClick -Handle $handle -X 351 -Y 150
    $captures.Add((Save-WindowScreenshot -Handle $handle -Path (Join-Path $OutputPath "05-settings-repair.png")))

    Invoke-WindowClick -Handle $handle -X 439 -Y 150
    $captures.Add((Save-WindowScreenshot -Handle $handle -Path (Join-Path $OutputPath "06-settings-logs.png")))

    $captures | Format-Table -AutoSize
  } else {
    Save-WindowScreenshot -Handle $handle -Path $OutputPath | Format-List
  }
} finally {
  if ($startedProcess -and -not $startedProcess.HasExited) {
    $startedProcess.CloseMainWindow() | Out-Null
    Start-Sleep -Milliseconds 500
    if (-not $startedProcess.HasExited) {
      $startedProcess.Kill()
    }
  }
}
