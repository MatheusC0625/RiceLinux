#!/bin/bash
# Controla a navegacao do carrossel
# Uso: nav.sh [left|right|apply]

WALL_DIR="$HOME/Pictures/wallpapers"
STATE_FILE="$HOME/.cache/wallpaper-carousel-index"

mapfile -t WALLS < <(find "$WALL_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) | sort)
TOTAL=${#WALLS[@]}

# Le o indice atual (default 0)
IDX=$(cat "$STATE_FILE" 2>/dev/null || echo 0)

case "$1" in
    left)  IDX=$(( (IDX - 1 + TOTAL) % TOTAL )) ;;
    right) IDX=$(( (IDX + 1) % TOTAL )) ;;
    apply)
        SELECTED_IMG="${WALLS[$IDX]}"
        swww img "$SELECTED_IMG" --transition-type grow --transition-pos top-left --transition-duration 1.5 --transition-fps 60
        echo "$SELECTED_IMG" > "$HOME/.config/hypr/.last_wallpaper"
        eww close wallpaper-carousel
        notify-send "Wallpaper" "Alterado para: $(basename "$SELECTED_IMG")"
        exit 0
        ;;
esac

# Salva o novo indice e atualiza o widget
echo "$IDX" > "$STATE_FILE"
CONTENT=$(~/.config/eww/wallpaper/gen-widget.sh "$IDX")
eww update carousel-content="$CONTENT"
