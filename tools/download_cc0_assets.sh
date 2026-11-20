#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$ROOT/assets/characters"
mkdir -p "$DEST"

BASE="https://gobkit.com/freebies/human004"
for model in Rifleman ReconScout ArmySniper CombatMedic; do
  target="$DEST/${model}.glb"
  if [[ ! -s "$target" ]]; then
    echo "Downloading CC0 character: ${model}"
    curl --fail --location --retry 3 --connect-timeout 20 "$BASE/${model}.glb" -o "$target"
  fi
  test -s "$target"
done

echo "CC0 character assets ready in $DEST"
