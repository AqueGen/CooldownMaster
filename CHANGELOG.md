## [2.1.3] - 2026-03-02

- Added Wago Addons distribution: releases now automatically publish to addons.wago.io

## Fix: Auto-sync false popup on every login

- **Fixed auto-sync showing "different layouts" popup every login** even when nothing changed. Blizzard's serializer embeds layout IDs that change when layouts are recreated, making data comparison unreliable. Replaced with timestamp-based tracking.
- Minimap icon changed to a standard Blizzard icon
- Simplified minimap button (single click to toggle window)
