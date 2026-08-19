#!/bin/bash
# Troca de wallpaper via Rofi (miniaturas) + swww (fade suave, sem flash)

WALLPAPER_DIR="$HOME/Pictures/wallpapers"

# Lista com miniaturas no Rofi
SELECTED=$(for img in "$WALLPAPER_DIR"/*.{png,jpg,jpeg}; do
    [ -f "$img" ] || continue
    name=$(basename "$img")
    printf "%s\x00icon\x1f%s\n" "$name" "$img"
done | rofi -dmenu -p "Wallpaper" -theme ~/.config/rofi/gruvbox.rasi)

# Se cancelou, sai
[ -z "$SELECTED" ] && exit 0

FULL_PATH="$WALLPAPER_DIR/$SELECTED"

# Aplica com swww (transicao fade suave, aplica em todos os monitores)
swww img "$FULL_PATH" --transition-type fade --transition-duration 1

# Salva a escolha para restaurar no proximo boot
echo "$FULL_PATH" > "$HOME/.config/hypr/.last_wallpaper"

notify-send "Wallpaper" "Alterado para: $SELECTED"
