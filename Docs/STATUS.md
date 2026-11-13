# SANGRAM development status

## Committed to main
- Unity 2022.3 project skeleton and package manifest
- Third-person character controller and follow camera
- Hitscan weapon, ammo and reload
- Health/damage component and simple practice enemy AI
- Shrinking safe-zone damage prototype
- Editor menu that generates a test arena with player, cover and bots
- Android touch HUD: movement joystick, right-side camera drag, fire, jump, sprint and reload
- EventSystem and Canvas generation for the mobile HUD
- Android build checklist updated for scene generation and touch testing

## Current limitation
This remains an early offline prototype foundation, not a finished battle royale game. The scene is generated locally in Unity using Tools > SANGRAM > Create Prototype Scene and is not committed as a generated scene asset. It has not been compiled in Unity or tested on a physical Android device here. Touch UI integration is committed but still requires Unity Editor and device validation.

## Next milestones
1. Offline match loop: player spawn, bot waves, elimination and results screen.
2. Loot pickups, inventory and weapon switching.
3. Indian village battlefield art, character/weapon models, animation, sound and VFX.
4. Multiplayer architecture and dedicated authoritative servers (separate major milestone).
5. Android profiling, device QA, signing and APK release.
