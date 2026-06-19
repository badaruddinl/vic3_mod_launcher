# Changelog

Format versi mengikuti SemVer: `MAJOR.MINOR.PATCH+BUILD`.

- `MAJOR`: perubahan besar atau breaking change.
- `MINOR`: fitur baru yang kompatibel.
- `PATCH`: bug fix atau perbaikan kecil.
- `BUILD`: nomor build installer/app untuk update detection.

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
