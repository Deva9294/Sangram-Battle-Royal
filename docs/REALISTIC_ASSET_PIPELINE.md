# Sangram 3D asset pipeline

## Assets now wired into the Android build

The GitHub Actions workflow downloads the following free CC0 binary assets into the Godot project before import/export, then commits them back to the build branch so they remain part of the project:

- Quaternius rigged humanoid GLB at `assets/characters/soldier/soldier.glb`.
- Quaternius Universal Animation Library GLB at `assets/animations/quaternius/universal-animation-library.glb`.
- Four Kenney City Kit Suburban building GLBs at `assets/environment/buildings/`.
- ambientCG Grass 007 albedo, normal and roughness maps at `assets/environment/grass/`.
- License notices at `assets/licenses/` and a source manifest at `assets/ASSET_SOURCES.md`.

Original sources:
- Quaternius character and animation packs: https://quaternius.com/ (CC0 1.0).
- Kenney City Kit Suburban models: https://kenney.nl/assets/city-kit-suburban (CC0 1.0).
- ambientCG Grass 007: https://ambientcg.com/view?id=Grass007 (CC0 1.0).

## Runtime integration

The player visual loader prefers the rigged GLB and retains the primitive blockout only as a fallback if the asset is missing. The training terrain now uses PBR grass albedo, normal and roughness maps when present. The training buildings load four modular Kenney GLB variants and use simple box collision volumes.

The separate animation library is bundled for the next retargeting pass. Its clips are not yet mapped onto the soldier skeleton; do not claim that full motion-capture locomotion/combat is already working. The Quaternius humanoid and Kenney city kit are game-ready stylized assets, not photoreal AAA assets.

## Remaining quality gate

After the first successful Android export, inspect the imported model's scale/orientation, animation skeleton compatibility, building placement, texture memory, draw calls, collision and frame rate on an Android device. A production Central India map, tactical soldier outfit/weapon rig, parachute sequence, lobby/matchmaking and online multiplayer remain separate tasks.
