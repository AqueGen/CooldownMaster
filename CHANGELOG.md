## New: Preset Profiles

- **Built-in preset profiles** — ready-to-use layouts from popular creators
- First preset: **Luxthos** (all classes supported)
- Presets appear in a dedicated section in the Profiles panel
- Presets are read-only — you can load them but not modify

## New: Auto-Sync on Login

Keep layouts synchronized across characters sharing the same profile.

- **Auto-Sync dropdown** in the bottom bar — pick one profile (user or preset) to sync on login
- Setting is **account-wide** — set it once, works on all characters
- On first login (not `/reload`), compares the selected profile's class layouts with current Blizzard CDM layouts
- If they differ, a WARNING popup offers **Apply & Reload** or **Skip**
- Comparison is thorough: layout count → names → serialized data (order-independent)
- Info button next to the dropdown explains how Auto-Sync works
