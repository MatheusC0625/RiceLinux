#!/bin/bash
WALL_DIR="$HOME/Pictures/wallpapers"
CACHE_DIR="$HOME/.cache/wallpaper-thumbs"
mkdir -p "$CACHE_DIR"

for img in "$WALL_DIR"/*.{png,jpg,jpeg}; do
    [ -f "$img" ] || continue
    name=$(basename "$img")
    thumb="$CACHE_DIR/${name}.thumb.png"
    if [ ! -f "$thumb" ]; then
        magick "$img" -resize 300x450^ -gravity center -extent 300x450 "$thumb"
    fi
done
echo "Miniaturas geradas em $CACHE_DIR"
