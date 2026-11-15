# SANGRAM — Offline Android Battle Royale Prototype

The active migration is being developed on the **godot-migration** branch using Godot 4.3 (free and open source). The original Unity starter files are retained in this branch as reference while the Godot version is validated.

## Godot project
- Open the repository root in Godot 4.3 or newer.
- Main scene: `scenes/main.tscn`
- Android export preset: `Android`
- Android CI workflow: `.github/workflows/godot-android.yml`

## Implemented prototype systems
- Offline third-person arena
- Procedural village-style environment with houses, trees and cover
- Player movement, aiming, hitscan firing, ammunition and reload
- 24 basic AI opponents
- Shrinking safe zone and outside-zone damage
- HUD and touch controls for movement, firing, jump and reload

## Controls
- Desktop: WASD to move, mouse to aim, left click to fire, R to reload, Space to jump.
- Android: use the on-screen movement/action buttons and drag on the right side to aim.

## Build status and scope
GitHub Actions is configured to export a **debug APK** and upload it as a workflow artifact when the Godot branch is updated. The APK is not considered ready until that workflow succeeds and the build is installed and tested on a real Android device.

This is an offline single-player prototype, not a finished online multiplayer game. Multiplayer matchmaking, loot/inventory, vehicles, parachute, anti-cheat, production art/audio, performance tuning and device QA remain future work.

Use only assets that you own or are properly licensed to use.
