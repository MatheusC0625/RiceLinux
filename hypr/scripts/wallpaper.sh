#!/bin/bash
# Troca de wallpaper via Rofi (miniaturas) + restart do hyprpaper
# Metodo estavel: escreve no config e reinicia o servico

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

# Escreve o novo wallpaper no config (sintaxe de bloco que funciona)
cat > "$HOME/.config/hypr/hyprpaper.conf" << EOF
ipc = on

preload = $FULL_PATH

wallpaper {
    monitor = eDP-1
    path = $FULL_PATH
}

wallpaper {
    monitor = HDMI-A-1
    path = $FULL_PATH
}

splash = false
EOF

# Reinicia o servico para aplicar (metodo estavel)
systemctl --user restart hyprpaper.service

notify-send "Wallpaper" "Alterado para: $SELECTED"
