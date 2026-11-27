# Sangram 3D asset pipeline

This branch intentionally keeps all third-party binary assets out of Git until their exact files and import settings are checked.

## Character + animation (CC0)
1. Download **Quaternius Universal Base Characters** (free glTF/FBX download): https://quaternius.com/packs/universalbasecharacters.html
2. Download **Quaternius Universal Animation Library**: https://quaternius.com/packs/universalanimationlibrary.html
3. Export/import a combat-ready regular-proportion humanoid with its humanoid skeleton and animation clips as glTF 2.0.
4. Put the exported scene at `assets/characters/soldier/soldier.glb`.
5. Keep the original `License.txt` files in `assets/licenses/`. Both pack pages identify the assets as CC0; retain a dated copy of the license with the release.

The character loader now prefers that GLB and uses its AnimationPlayer when present. It falls back to the clearly labelled primitive blockout if the file is absent. Clip names vary by export; the loader probes common Idle/Walk/Run/Sprint names. Verify and map the exact clip names after import.

## Buildings and PBR
- Modular buildings: Kenney City Kit Suburban / Modular Buildings, CC0: https://kenney.nl/assets/city-kit-suburban and https://kenney.nl/assets/modular-buildings
- PBR materials: ambientCG CC0 materials: https://ambientcg.com/
- HDR environment maps: Poly Haven CC0: https://polyhaven.com/

Place optimized GLB building scenes in `assets/environment/buildings/`, tileable albedo/normal/roughness/AO maps in `assets/environment/materials/`, and HDRI files in `assets/environment/hdri/`. Use 1K textures for mobile initially; enable mipmaps and texture compression before shipping.

## Important quality gate
The current branch does not yet contain the downloaded binary assets. Do not describe the blockout as a realistic soldier, motion-capture animation, or production building set. After importing the actual packs, inspect scale, skeleton, clip names, materials, collision, draw calls and Android memory use in Godot before making an APK.
