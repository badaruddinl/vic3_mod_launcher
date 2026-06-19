# Victoria 3 Mod Launcher

Launcher Windows untuk Victoria 3 berbasis Flutter.

Fitur utama:

- Deteksi game dari shortcut Desktop `Victoria 3.lnk`.
- Fallback path game: `D:\Victoria 3`, `D:\Game\Victoria 3`, `D:\Games\Victoria 3`, `D:\Victoria3`.
- Scan mod dari `Documents\Paradox Interactive\Victoria 3\mod`.
- Import mod `.zip`, auto extract, dan auto buat `descriptor.mod` / `.mod` jika belum ada.
- Atur enable/disable mod dan urutan mod aktif.
- Scan DLC dari folder game dan simpan mod/DLC aktif ke `content_load.json`.
- Entry mod di `content_load.json` memakai path absolut folder mod, misalnya `C:/Users/.../Victoria 3/mod/my_mod`.
- Parse versi game dari `launcher-settings.json` dan cek `supported_version` mod.
- Tombol `Debug mode` untuk launch dengan argumen `-debug_mode`.

## Struktur

- `lib/main.dart`: entrypoint.
- `lib/app.dart`: konfigurasi Material app.
- `lib/screens/launcher_home.dart`: state utama launcher.
- `lib/widgets/`: komponen UI.
- `lib/services/`: deteksi path, config, parser descriptor, JSON.
- `lib/models.dart`: model `ModInfo`, `DlcInfo`, status versi.

## Jalankan dari source

```powershell
flutter pub get
flutter run -d windows
```

## Build release

```powershell
.\scripts\build_release.ps1
```

Output release ada di:

```text
build\windows\x64\runner\Release\vic3_mod_launcher.exe
```

ZIP portable dibuat di:

```text
dist\Vic3ModLauncher-portable.zip
```

## Install lokal

Setelah build:

```powershell
.\scripts\install_local.ps1
```

Script akan copy app ke:

```text
%LOCALAPPDATA%\Vic3ModLauncher
```

Lalu membuat shortcut:

```text
Desktop\Victoria 3 Mod Launcher.lnk
```

Config launcher disimpan di:

```text
%APPDATA%\Vic3ModLauncher\config.json
```
