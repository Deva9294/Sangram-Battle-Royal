# SANGRAM — Godot Battle Royale

Active development branch: `godot-migration`  
Engine: Godot 4.3  
Android target: ARM64 debug APK

## Game modes

### Offline Battle Royale
The current playable foundation is an offline, single-player arena with AI opponents, player movement, hitscan weapon firing, ammo/reload, loot pickups, a shrinking safe zone and Android touch controls. It remains a prototype and is not yet a production-quality Battle Royale.

### Online multiplayer — in progress
The project now includes an ENet session transport foundation:
- Host a session on UDP port 2456
- Join a host by IP address
- Track peer connect/disconnect and connection failures
- Lobby exposes offline deploy, host and join actions

**Important:** ENet host/join transport is not equivalent to a finished multiplayer game. Network-authoritative player spawning, movement replication, combat validation, health/inventory/loot replication, match lifecycle, reconnection and dedicated-server deployment are still required before online matches can be called playable. Internet play may require a reachable host/public IP and UDP port forwarding; mobile carrier NAT can prevent direct peer hosting.

## Remaining production milestones

1. Authoritative multiplayer session and player spawn/replication.
2. Server-validated weapons, damage, inventory and loot state.
3. Full match flow: lobby, matchmaking, aircraft route, jump, parachute, safe-zone phases, spectating and victory.
4. Expanded, authored 3D map and production character/weapon animations, audio and effects.
5. Dedicated server deployment, latency handling, disconnect/reconnect and anti-cheat.
6. Android device QA, performance profiling and release signing.

## Open and build

- Open the repository root in Godot 4.3 or newer.
- Main scene: `scenes/main.tscn`
- Android export preset: `Android`
- CI workflow: `.github/workflows/godot-android.yml`

A successful debug APK export only confirms that the project exported. It does not certify online multiplayer, production visuals, or device compatibility. Do not label the game complete until those milestones are tested.
