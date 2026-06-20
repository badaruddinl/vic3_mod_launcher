# Changelog

Format versi mengikuti SemVer: `MAJOR.MINOR.PATCH+BUILD`.

- `MAJOR`: perubahan besar atau breaking change.
- `MINOR`: fitur baru yang kompatibel.
- `PATCH`: bug fix atau perbaikan kecil.
- `BUILD`: nomor build installer/app untuk update detection.

## 1.2.0+11 - 2026-06-20

### Added

- Added portrait UI audit capture script for Home, General, Mods, DLC, Repair, and Logs tabs.
- Added a dedicated Logs tab in Settings.
- Added global tooltip behavior for ellipsized UI text.
- Added cleaned mod display names for workshop/version-prefixed mod folders.

### Changed

- Refined the portrait launcher UI with a roomier Home screen and bottom `Mods in use` panel.
- Moved live logs out of Home into the new Logs tab.
- Simplified the Settings header to reduce wasted vertical space.
- Improved General tab balance and made Auto Detect an explicit action panel.
- Made the Victoria backdrop image more visible behind the UI.

## 1.1.4+10 - 2026-06-19

### Fixed

- Let the installer close and relaunch the app during updates instead of exiting the launcher immediately after starting setup.

## 1.1.3+9 - 2026-06-19

### Fixed

- Force-close the running launcher during silent updates so app files can be replaced reliably.

## 1.1.2+8 - 2026-06-19

### Fixed

- Reopen the launcher from the silent installer after an update completes.
- Keep the normal installer finish page launch option for manual installs.

## 1.1.1+7 - 2026-06-19

### Fixed

- Reopen the launcher automatically after a silent update installer completes.

## 1.1.0+6 - 2026-06-19

### Added

- Added automatic update check after launcher startup.
- Added red update indicator on the update menu icon when a new version is available.
- Added startup snackbar notification with a quick `View` action for available updates.

## 1.0.4+5 - 2026-06-19

### Fixed

- Added cache-busting to update manifest and installer HTTP downloads.
- Generated update manifests now point to version-specific installer assets instead of the moving `latest` URL.

## 1.0.3+4 - 2026-06-19

### Added

- Added persistent launcher logs in `%APPDATA%\Vic3ModLauncher\logs`.
- Added log rotation for `launcher.log` after it reaches 1 MB, keeping 5 rotated files.
- Added `Open Logs` from the update menu.

### Changed

- Update installer handoff now logs each step for tracing.
- Update installer is launched with Inno Setup silent arguments so updates can continue after UAC without manual wizard steps.

## 1.0.2+3 - 2026-06-19

### Fixed

- Fixed update flow stopping at a confirmation dialog after launching the installer.
- Launches the downloaded installer directly, then closes the launcher so the installer can replace app files.

## 1.0.1+2 - 2026-06-19

### Fixed

- Fixed update checks from public GitHub Releases.
- Fixed local Windows file paths such as `D:\...\latest.local-test.json` being parsed as unsupported URLs.
- Fixed update manifest encoding so `latest.json` is written as UTF-8 without BOM.

### Changed

- GitHub release update assets are now public-readable through the default update URL.

## 1.0.0+1 - 2026-06-19

### Added

- Initial Victoria 3 launcher release.
- Game launch without Steam integration.
- Victoria 3 game/data path detection.
- Mod scanning, enabling, disabling, and ordering.
- DLC disable list support through `content_load.json`.
- ZIP mod import and descriptor repair.
- Debug mode launch option.
- Named playsets.
- Installer built with Inno Setup.
