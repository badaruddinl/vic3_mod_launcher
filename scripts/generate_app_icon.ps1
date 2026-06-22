$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$brandDir = Join-Path $root "assets\brand"
$iconPath = Join-Path $root "windows\runner\resources\app_icon.ico"
$previewPath = Join-Path $brandDir "app_icon_256.png"

New-Item -ItemType Directory -Force -Path $brandDir | Out-Null
Add-Type -AssemblyName System.Drawing

function New-Vic3LauncherIconBitmap {
  param([Parameter(Mandatory = $true)][int]$Size)

  $scale = $Size / 256.0
  function S([double]$Value) {
    return [single]($Value * $scale)
  }

  $bmp = [System.Drawing.Bitmap]::new($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
  $g.Clear([System.Drawing.Color]::Transparent)

  $gold = [System.Drawing.Color]::FromArgb(255, 212, 161, 88)
  $goldDark = [System.Drawing.Color]::FromArgb(255, 117, 78, 37)
  $cream = [System.Drawing.Color]::FromArgb(255, 246, 225, 186)
  $teal = [System.Drawing.Color]::FromArgb(255, 8, 78, 72)
  $ink = [System.Drawing.Color]::FromArgb(255, 7, 19, 20)

  $outer = [System.Drawing.RectangleF]::new((S 9), (S 9), (S 238), (S 238))
  $bgBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    $outer,
    [System.Drawing.Color]::FromArgb(255, 10, 22, 23),
    $teal,
    [System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal
  )
  $g.FillEllipse($bgBrush, $outer)
  $bgBrush.Dispose()

  $g.DrawEllipse([System.Drawing.Pen]::new($goldDark, (S 7)), $outer)
  $g.DrawEllipse([System.Drawing.Pen]::new($gold, (S 2.5)), [System.Drawing.RectangleF]::new((S 17), (S 17), (S 222), (S 222)))
  $g.DrawEllipse([System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(180, 242, 207, 144), (S 1.5)), [System.Drawing.RectangleF]::new((S 30), (S 30), (S 196), (S 196)))

  $leafBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(235, 186, 137, 72))
  $stemPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(210, 160, 113, 60), (S 2))
  for ($i = 0; $i -lt 8; $i++) {
    $angle = (214 + ($i * 12)) * [Math]::PI / 180.0
    $x = 128 + [Math]::Cos($angle) * 72
    $y = 128 + [Math]::Sin($angle) * 72
    $g.FillEllipse($leafBrush, [System.Drawing.RectangleF]::new((S ($x - 8)), (S ($y - 4)), (S 17), (S 8)))
    $angleR = (326 - ($i * 12)) * [Math]::PI / 180.0
    $xr = 128 + [Math]::Cos($angleR) * 72
    $yr = 128 + [Math]::Sin($angleR) * 72
    $g.FillEllipse($leafBrush, [System.Drawing.RectangleF]::new((S ($xr - 8)), (S ($yr - 4)), (S 17), (S 8)))
  }
  $g.DrawArc($stemPen, [System.Drawing.RectangleF]::new((S 49), (S 72), (S 158), (S 158)), 125, 110)
  $g.DrawArc($stemPen, [System.Drawing.RectangleF]::new((S 49), (S 72), (S 158), (S 158)), 305, 110)
  $leafBrush.Dispose()
  $stemPen.Dispose()

  $family = [System.Drawing.FontFamily]::new("Georgia")
  $format = [System.Drawing.StringFormat]::new()
  $format.Alignment = [System.Drawing.StringAlignment]::Center
  $format.LineAlignment = [System.Drawing.StringAlignment]::Center

  $shadow = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $shadow.AddString("V", $family, [int][System.Drawing.FontStyle]::Bold, (S 157), [System.Drawing.RectangleF]::new((S 40), (S 51), (S 138), (S 148)), $format)
  $matrix = [System.Drawing.Drawing2D.Matrix]::new()
  $matrix.Translate((S 5), (S 5))
  $shadow.Transform($matrix)
  $g.FillPath([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(135, 0, 0, 0)), $shadow)
  $shadow.Dispose()
  $matrix.Dispose()

  $vPath = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $vPath.AddString("V", $family, [int][System.Drawing.FontStyle]::Bold, (S 157), [System.Drawing.RectangleF]::new((S 36), (S 46), (S 138), (S 148)), $format)
  $g.DrawPath([System.Drawing.Pen]::new($ink, (S 8)), $vPath)
  $g.DrawPath([System.Drawing.Pen]::new($goldDark, (S 3)), $vPath)
  $g.FillPath([System.Drawing.SolidBrush]::new($cream), $vPath)

  $threePath = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $threePath.AddString("3", $family, [int][System.Drawing.FontStyle]::Bold, (S 81), [System.Drawing.RectangleF]::new((S 126), (S 29), (S 80), (S 77)), $format)
  $g.DrawPath([System.Drawing.Pen]::new($ink, (S 6)), $threePath)
  $g.DrawPath([System.Drawing.Pen]::new($goldDark, (S 2)), $threePath)
  $g.FillPath([System.Drawing.SolidBrush]::new($cream), $threePath)

  $vPath.Dispose()
  $threePath.Dispose()
  $family.Dispose()
  $format.Dispose()
  $g.Dispose()
  return $bmp
}

function Convert-BitmapToPngBytes {
  param([Parameter(Mandatory = $true)][System.Drawing.Bitmap]$Bitmap)
  $stream = [System.IO.MemoryStream]::new()
  $Bitmap.Save($stream, [System.Drawing.Imaging.ImageFormat]::Png)
  return ,$stream.ToArray()
}

$sizes = @(256, 128, 64, 48, 32, 16)
$images = @()
foreach ($size in $sizes) {
  $bitmap = New-Vic3LauncherIconBitmap -Size $size
  if ($size -eq 256) {
    $bitmap.Save($previewPath, [System.Drawing.Imaging.ImageFormat]::Png)
  }
  $images += [pscustomobject]@{
    Size = $size
    Data = [byte[]](Convert-BitmapToPngBytes -Bitmap $bitmap)
  }
  $bitmap.Dispose()
}

$writer = [System.IO.BinaryWriter]::new([System.IO.File]::Open($iconPath, [System.IO.FileMode]::Create))
try {
  $writer.Write([UInt16]0)
  $writer.Write([UInt16]1)
  $writer.Write([UInt16]$images.Count)

  $offset = 6 + (16 * $images.Count)
  foreach ($image in $images) {
    $sizeByte = if ($image.Size -eq 256) { 0 } else { $image.Size }
    $writer.Write([byte]$sizeByte)
    $writer.Write([byte]$sizeByte)
    $writer.Write([byte]0)
    $writer.Write([byte]0)
    $writer.Write([UInt16]1)
    $writer.Write([UInt16]32)
    $writer.Write([UInt32]$image.Data.Length)
    $writer.Write([UInt32]$offset)
    $offset += $image.Data.Length
  }

  foreach ($image in $images) {
    $writer.Write([byte[]]$image.Data)
  }
} finally {
  $writer.Dispose()
}

Write-Host "Icon written: $iconPath"
Write-Host "Preview written: $previewPath"
