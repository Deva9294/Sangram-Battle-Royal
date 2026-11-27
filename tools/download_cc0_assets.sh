#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHAR_DIR="$ROOT/assets/characters"
WORLD_DIR="$ROOT/assets/environment"
BUILDING_DIR="$WORLD_DIR/buildings"
WEAPON_DIR="$ROOT/assets/weapons"
TEXTURE_DIR="$WORLD_DIR/textures/ground037"
mkdir -p "$CHAR_DIR" "$BUILDING_DIR" "$WEAPON_DIR" "$TEXTURE_DIR"

download() {
  local url="$1"
  local target="$2"
  if [[ ! -s "$target" ]]; then
    echo "Downloading asset: $target"
    curl --fail --location --retry 3 --connect-timeout 20 "$url" -o "$target"
  fi
  test -s "$target"
}

# CC0 rigged soldier models (Gobkit).
CHAR_BASE="https://gobkit.com/freebies/human004"
for model in Rifleman ReconScout ArmySniper CombatMedic; do
  download "$CHAR_BASE/$model.glb" "$CHAR_DIR/$model.glb"
done

# CC0 Kenney City Kit Suburban building and tree models.
ENV_BASE="https://raw.githubusercontent.com/petroulacl/fps-buildings-env-kit/main"
for model in building-type-a building-type-b building-type-d building-type-h tree-large tree-small; do
  download "$ENV_BASE/buildings/kenney-city-kit-suburban/Models/GLB%20format/$model.glb" "$BUILDING_DIR/$model.glb"
done

# CC0 OpenGameArt Flat Guns West assault rifle model.
WEAPON_BASE="https://raw.githubusercontent.com/petroulacl/fps-asset-kit/main"
download "$WEAPON_BASE/weapons/flat_guns_west/Flat%20Guns%20West/GLB/Rifle_Assault_West.glb" "$WEAPON_DIR/Rifle_Assault_West.glb"

# CC0 ambientCG Ground037 PBR maps (2K): base color, OpenGL normal and roughness.
TEX_BASE="$WEAPON_BASE/textures/Ground037"
download "$TEX_BASE/Ground037_2K-JPG_Color.jpg" "$TEXTURE_DIR/Ground037_Color.jpg"
download "$TEX_BASE/Ground037_2K-JPG_NormalGL.jpg" "$TEXTURE_DIR/Ground037_NormalGL.jpg"
download "$TEX_BASE/Ground037_2K-JPG_Roughness.jpg" "$TEXTURE_DIR/Ground037_Roughness.jpg"

echo "CC0 characters, buildings, trees, rifle and Ground037 PBR maps are ready."
