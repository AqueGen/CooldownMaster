# Changelog

## 2.0.1

- Replaced direct ReloadUI with a confirmation popup ("Reload Now" / "Later") when loading profiles
- Fixed layout desync: call SaveLayouts() before reload in LoadGlobalProfile
- Clear stale layout name overrides when loading profiles
- Removed stored layouts system and individual layout operations (dead code cleanup)
- Removed active layout highlighting and spec-based dimming from Blizzard Layouts section (now informational only)
- Renamed all popup dialogs from COOLDOWNMASTER to CMP prefix
- Added reactive UI updates — subscribes to CooldownViewerSettings.OnDataChanged
- Removed confirmation popup when removing a layout from a profile (X button) for faster workflow
- Removed chat spam for routine UI operations (rename, delete, add to profile, save to library) — errors are still shown

## 2.0.0

### Renamed addon to Cooldown Manager Profiles

The addon has been renamed from **CooldownMaster** to **CooldownManagerProfiles** for clarity and consistency.

**What changed:**
- Addon folder: `CooldownMaster` → `CooldownManagerProfiles`
- TOC file: `CooldownMaster.toc` → `CooldownManagerProfiles.toc`
- SavedVariables: `CooldownMasterDB` → `CooldownManagerProfilesDB`
- CurseForge package name updated

**Migration required:** If you are upgrading from CooldownMaster, your saved profiles need a one-time manual migration. See the [Migration Guide](README.md#migrating-from-cooldownmaster) in the README.

### Other changes
- Profile switching and import target dropdown improvements
- Frameless colored text buttons in row actions (Rename, Export, +Library, +Profile, X)
- Blizzard layout click-to-activate with spec restriction display
- UI polish and layout fixes
- Fixed "Unknown class" header for Blizzard layouts

## 1.1.0

- Global Profiles: account-wide profiles with layouts organized by class
- Template Library: save and reuse individual layouts
- Full import/export (profiles, class layouts, individual layouts, raw CDM strings)
- Conflict resolution on import (copy or overwrite)
- Sync from/to Blizzard Cooldown Manager
- Minimap button with left-click/right-click actions
- Resizable three-column UI
- Settings panel (ESC → AddOns)
