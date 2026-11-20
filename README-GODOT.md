# SANGRAM — MP Lobby and Offline Battle Royale prototype

Godot 4.3 Android migration track. Original Unity project and main branch remain untouched while this upgrade is developed on `mp-lobby-upgrade`.

## Current prototype scope
- New deployment lobby with three selectable fictional operators and a 3D hangar preview
- Operator preview has basic gear/rifle silhouette and subtle idle motion
- Deploy button opens the offline Malwa Frontier battlefield
- Madhya Pradesh-inspired rural environment: village clusters, fields, lanes, stream crossing and tree belts
- Third-person movement with walk/sprint/crouch/prone, jump, camera ADS/FOV transitions, hitscan shooting, ammo/reload and 24 simple chasing AI bots
- Mobile touch controls for movement, aim, sprint, crouch, prone, fire, jump and reload
- Battlefield loot pickups: ammo, medkits and armor; armor absorbs part of incoming damage
- Shrinking safe zone, health/ammo HUD and a live enemy radar minimap
- Android touch buttons for movement, aim, fire, jump and reload

## Controls
- Desktop: WASD, mouse aim, left click fire, R reload, Space jump
- Android: on-screen movement/fire/reload/jump controls; drag the right side to aim

## Important production gaps
This is still an early offline prototype. The lobby character and world are procedural placeholder geometry, not photorealistic production assets. It does not yet include rigged character animation, high-resolution PBR texture packs, full terrain heightmap, loot/inventory, parachute, vehicles, online multiplayer, anti-cheat or real-device QA.

The requested separate large-world data package (PCK/OBB-style delivery) is not wired yet. A Godot PCK sidecar needs an in-game download/load path; a legacy Android OBB file is not automatically consumed by this build.

## Build
Use Godot 4.3+ with the Android export templates and the Android preset in `export_presets.cfg`. The CI workflow is configured for both `godot-migration` and `mp-lobby-upgrade`.
