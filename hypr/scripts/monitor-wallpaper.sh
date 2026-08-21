#!/bin/bash
# Escuta eventos do Hyprland e reaplica wallpaper quando um monitor e conectado

handle() {
    case "$1" in
        monitoradded*)
            # Espera o monitor estabilizar e reaplica o wallpaper em todas as telas
            sleep 1
            swww img "$(cat ~/.config/hypr/.last_wallpaper 2>/dev/null || echo ~/Pictures/wallpapers/anime-gruvbox.png)" --transition-type fade --transition-duration 1
            ;;
    esac
}

# Conecta no socket de eventos do Hyprland
socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
    handle "$line"
done
