# SANGRAM — India's Battle Royale

Unity 3D Android game starter. This repository contains the source foundation for an offline third-person shooter prototype.

## Requirements
- Unity 2022.3 LTS
- Android Build Support, Android SDK & NDK Tools, OpenJDK (install through Unity Hub)

## Setup
1. Create a Unity 3D (Core) project.
2. Copy this repository's `Assets` folder into the Unity project.
3. Open the project and run **Tools > SANGRAM > Create Prototype Scene**.
4. Open `Assets/SANGRAM/Scenes/SANGRAM_Prototype.unity` and press Play.
5. To build Android: File > Build Settings > Android > Switch Platform. Set package id to `in.devacore.sangram`, Landscape orientation, then Build.

## Prototype controls
- WASD: move
- Mouse: rotate camera
- Shift: sprint
- Space: jump
- Left mouse: fire
- R: reload

## Included
- Third-person movement and camera
- Hitscan weapon with ammo/reload
- Health and simple practice enemy AI
- Shrinking safe-zone damage prototype
- Unity Editor scene generator

## Roadmap / not yet included
Touch HUD, production art/audio, inventory and loot, parachute, vehicles, online matchmaking, authoritative multiplayer servers, anti-cheat, account/progression systems, 50–100 player hosting, device QA and signed release APK. These are future milestones; this starter is not yet a finished multiplayer game or APK.

Use only assets that you own or are properly licensed to use.
