#!/bin/bash
# Comando executado ao selecionar um wallpaper ($1 = caminho da imagem)
swww img "$1" --transition-type grow --transition-pos top-left --transition-duration 1.5 --transition-fps 60
echo "$1" > "$HOME/.config/hypr/.last_wallpaper"
notify-send "Wallpaper" "Alterado para: $(basename "$1")"
