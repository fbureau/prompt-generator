#!/usr/bin/env bash
# Render an OpenSCAD file to STL (and optionally a PNG preview).
#
# Usage:
#   render.sh model.scad [output.stl] [--png]
#
# Examples:
#   render.sh part.scad                 # -> part.stl
#   render.sh part.scad build/part.stl  # -> build/part.stl
#   render.sh part.scad --png           # -> part.stl and part.png
set -euo pipefail

scad="${1:-}"
if [[ -z "$scad" ]]; then
    echo "usage: render.sh <model.scad> [output.stl] [--png]" >&2
    exit 2
fi
if [[ ! -f "$scad" ]]; then
    echo "error: no such file: $scad" >&2
    exit 2
fi

out=""
want_png=0
shift
for arg in "$@"; do
    case "$arg" in
        --png) want_png=1 ;;
        *)     out="$arg" ;;
    esac
done
[[ -z "$out" ]] && out="${scad%.scad}.stl"

if ! command -v openscad >/dev/null 2>&1; then
    echo "openscad not found on PATH. Install it: https://openscad.org/downloads.html" >&2
    echo "The .scad file is the source of truth and is still valid without a render." >&2
    exit 127
fi

mkdir -p "$(dirname "$out")"
openscad -o "$out" "$scad"
echo "wrote $out"

if [[ "$want_png" -eq 1 ]]; then
    png="${out%.stl}.png"
    openscad -o "$png" "$scad"
    echo "wrote $png"
fi
