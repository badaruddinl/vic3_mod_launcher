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

## Build installer `.exe`

Installer dibuat dengan Inno Setup. Jika belum ada:

```powershell
winget install --id JRSoftware.InnoSetup -e
```

```powershell
.\scripts\build_installer.ps1
```

Output:

```text
dist\Vic3ModLauncher-Setup.exe
```

Installer ini memakai wizard standar Windows/Inno Setup:

- `Install`: install ke folder pilihan, default `C:\Program Files\Victoria 3 Mod Launcher`.
- `Update`: jalankan installer versi baru di atas instalasi lama; Inno akan memakai folder install sebelumnya.
- `Uninstall`: lewat Windows Installed Apps atau shortcut Start Menu.

Jika folder tujuan berada di `Program Files`, installer akan meminta izin administrator lewat UAC.

Installer juga membuat:

```text
Desktop\Victoria 3 Mod Launcher.lnk
Start Menu\Victoria 3 Mod Launcher\Victoria 3 Mod Launcher.lnk
Start Menu\Victoria 3 Mod Launcher\Uninstall Victoria 3 Mod Launcher.lnk
```

Uninstaller bawaan Inno disimpan di folder install sebagai `unins000.exe` dan didaftarkan ke Windows Installed Apps.

File runtime pendukung Flutter Windows seperti `flutter_windows.dll` dan folder `data\flutter_assets` tetap dibutuhkan agar app berjalan. Installer memberi atribut hidden pada file/folder pendukung tersebut, sehingga folder install normalnya hanya menampilkan launcher dan uninstaller di Explorer default.

## Update release

App mengecek update dari manifest JSON. Default URL:

```text
https://github.com/badaruddinl/vic3_mod_launcher/releases/latest/download/latest.json
```

URL GitHub Release ini hanya bisa dibaca app jika release asset tersedia dan repo/release bisa diakses publik. Jika repo masih private, GitHub akan mengembalikan HTTP 404 ke app karena app tidak membawa token GitHub.

Di aplikasi, buka menu update di kanan atas:

- `Check for Updates`: cek versi terbaru.
- `Update Source`: ganti URL manifest, termasuk ke file lokal untuk testing.

Build installer juga membuat manifest:

```text
dist\latest.json
dist\latest.local-test.json
```

Isi manifest:

```json
{
  "version": "1.0.1",
  "buildNumber": 2,
  "installerUrl": "https://github.com/badaruddinl/vic3_mod_launcher/releases/latest/download/Vic3ModLauncher-Setup.exe",
  "sha256": "...",
  "publishedAt": "2026-06-19T00:00:00Z",
  "notes": "Release notes"
}
```

Alur release:

1. Naikkan `version` di `pubspec.yaml`, contoh `1.0.1+2`.
2. Tambahkan entry di `CHANGELOG.md` dengan heading yang sama, contoh `## 1.0.1+2 - 2026-06-19`.
3. Jalankan `.\scripts\build_installer.ps1`.
4. Upload `dist\Vic3ModLauncher-Setup.exe` dan `dist\latest.json` ke GitHub Release atau hosting publik.
5. App terinstall akan melihat update jika versi manifest lebih baru dari versi lokal.

Aturan versi:

- `MAJOR`: breaking change.
- `MINOR`: fitur baru yang kompatibel.
- `PATCH`: bug fix atau perbaikan kecil.
- `BUILD`: nomor build installer/app untuk update detection.

Untuk repo private, jangan pakai URL release private sebagai update source aplikasi publik. Pilih salah satu:

- jadikan release repo publik;
- upload `latest.json` dan installer ke hosting publik;
- pakai file lokal `latest.local-test.json` hanya untuk testing.

Untuk test mekanisme update lokal:

1. Install app dari `dist\Vic3ModLauncher-Setup.exe`.
2. Buka app, pilih menu update di kanan atas.
3. Pilih `Update Source`.
4. Isi path lokal:

```text
D:\Victoria3Mods\dump-elevated-true\dist\latest.local-test.json
```

5. Pilih `Check for Updates`.

Manifest lokal ini sengaja memakai build number lebih tinggi dan menunjuk ke installer lokal yang baru dibuat.
