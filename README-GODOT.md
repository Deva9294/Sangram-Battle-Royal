# SANGRAM — MP Lobby and Offline Battle Royale prototype

Godot 4.3 Android migration track. Original Unity project and main branch remain untouched while this upgrade is developed on `mp-lobby-upgrade`.

## Current prototype scope
- New deployment lobby with three selectable fictional operators and a 3D hangar preview
- Operator preview has basic gear/rifle silhouette and subtle idle motion
- Deploy button opens the offline Malwa Frontier battlefield
- Madhya Pradesh-inspired rural environment: village clusters, fields, lanes, stream crossing and tree belts
- Third-person player controller with walk/sprint/crouch/prone, jump, camera look, ADS/FOV transitions, hitscan rifle fire, recoil and reload
- Rigged, animated soldier models (Rifleman, Recon Scout, Army Sniper and Combat Medic) with Idle/Walk/Run/Death animations; procedural fallback if assets are not present
- 24 armed AI opponents that pursue, check line of sight and fire at the player
- Mobile analog movement joystick plus aim, sprint, crouch, prone, fire, jump and reload touch controls
- Battlefield pickups: ammo, medkits and armor; armor absorbs part of incoming damage, medkits restore health
- Shrinking safe zone, health/ammo HUD and a live enemy radar minimap
- Android touch controls for movement, aim, fire, jump, reload, pickup and medkit

## Controls
- Desktop: WASD, mouse aim, left click fire, R reload, Space jump
- Android: on-screen movement/fire/reload/jump controls; drag the right side to aim

## Important production gaps
This is an early offline gameplay prototype, not a finished photorealistic commercial game. Soldier visuals and much of the environment are still procedural meshes. Production work remains: rigged character animations, high-quality PBR assets, detailed terrain, proper weapon animations/audio, parachute, vehicles, navigation-mesh AI, performance profiling and real-device QA. Online multiplayer and anti-cheat are not implemented.

The requested separate large-world data package (PCK/OBB-style delivery) is not wired yet. A Godot PCK sidecar needs an in-game download/load path; a legacy Android OBB file is not automatically consumed by this build.

## Build
Use Godot 4.3+ with the Android export templates and the Android preset in `export_presets.cfg`. Before opening the project locally, run `bash tools/download_cc0_assets.sh` once to fetch the CC0 GLB soldier models; they are then bundled into the APK for offline play. The CI workflow performs this step automatically and runs lobby plus 60-second battle-scene smoke tests before exporting.
