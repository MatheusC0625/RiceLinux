#!/bin/bash
# Aplica o wallpaper escolhido com o efeito de circulo e fecha o carrossel

FULL_PATH="$1"

swww img "$FULL_PATH" --transition-type grow --transition-pos top-left --transition-duration 1.5 --transition-fps 60

# Salva para restaurar no boot
echo "$FULL_PATH" > "$HOME/.config/hypr/.last_wallpaper"

# Fecha o carrossel
eww close wallpaper-carousel

notify-send "Wallpaper" "Alterado para: $(basename "$FULL_PATH")"
