# SANGRAM — Godot offline Android prototype

This is the Godot 4 migration track. The original Unity source is retained for reference; this project uses only Godot and generated primitive art, with no paid assets or online services.

## Current playable scope
- Offline single-player third-person arena prototype
- Procedurally generated village-style arena, houses, trees and cover
- Third-person player, hitscan shooting, ammo and reload
- 24 simple AI opponents that chase and attack
- Shrinking safe zone with damage outside the ring
- Health/ammo/enemy HUD and touch buttons for movement, aim, fire, jump and reload

## Controls
- Desktop: WASD, mouse aim, left click fire, R reload, Space jump
- Android: on-screen movement/fire/reload/jump controls; drag the right side to aim

## Build
Open this folder in Godot 4.3+ (GL Compatibility renderer). Configure an Android export preset and export a debug APK. This is an offline prototype, not a finished commercial battle-royale product: it has no multiplayer, parachute, loot/inventory, vehicles, anti-cheat or production device QA yet.
