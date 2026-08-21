#!/bin/bash
# Abre ou fecha o carrossel de wallpapers (seguro, com submap do Hyprland)

if eww active-windows | grep -q "wallpaper-carousel"; then
    eww close wallpaper-carousel
    hyprctl dispatch submap reset
    exit 0
fi

# Garante miniaturas
~/.config/eww/wallpaper/gen-thumbs.sh > /dev/null

# Reseta o indice e gera o conteudo
echo 0 > "$HOME/.cache/wallpaper-carousel-index"
CONTENT=$(~/.config/eww/wallpaper/gen-widget.sh 0)
eww update carousel-content="$CONTENT"

# Abre a janela e ativa o submap de navegacao
eww open wallpaper-carousel
hyprctl dispatch submap wallpaper
