#!/bin/bash
# Gera o carrossel com efeito de profundidade (distancia do selecionado)
WALL_DIR="$HOME/Pictures/wallpapers"
CACHE_DIR="$HOME/.cache/wallpaper-thumbs"
SELECTED=${1:-0}

mapfile -t WALLS < <(find "$WALL_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) | sort)

echo -n "(box :class \"carousel\" :orientation \"horizontal\" :space-evenly false :spacing 12 :halign \"center\" :valign \"center\" "

i=0
for img in "${WALLS[@]}"; do
    name=$(basename "$img")
    thumb="$CACHE_DIR/${name}.thumb.png"
    # calcula distancia do selecionado
    dist=$(( i - SELECTED )); dist=${dist#-}
    if [ "$dist" -eq 0 ]; then
        cls="wall-item d0"
    elif [ "$dist" -eq 1 ]; then
        cls="wall-item d1"
    elif [ "$dist" -eq 2 ]; then
        cls="wall-item d2"
    else
        cls="wall-item d3"
    fi
    echo -n "(box :class \"$cls\" (box :class \"wall-img\" :style \"background-image: url(\'$thumb\');\"))"
    i=$((i+1))
done
echo -n ")"
