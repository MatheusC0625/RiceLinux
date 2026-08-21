#!/bin/bash
# Recebe a tecla pressionada e chama a acao correspondente
KEY="$1"

case "$KEY" in
    Left|h)  ~/.config/eww/wallpaper/nav.sh left ;;
    Right|l) ~/.config/eww/wallpaper/nav.sh right ;;
    Return|space) ~/.config/eww/wallpaper/nav.sh apply ;;
    Escape) eww close wallpaper-carousel ;;
esac
