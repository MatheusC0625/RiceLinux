#!/bin/bash
# Gravacao de tela com selecao de area (toggle: liga/desliga)

# Se ja estiver gravando, para e salva
if pgrep -x wf-recorder > /dev/null; then
    pkill -INT -x wf-recorder
    notify-send "Gravacao" "Video salvo em ~/Videos"
    exit 0
fi

# Cria a pasta de videos se nao existir
mkdir -p "$HOME/Videos"

# Nome do arquivo com data/hora
FILE="$HOME/Videos/grava_$(date +%Y-%m-%d_%H-%M-%S).mp4"

# Seleciona a area com slurp e grava
GEOMETRY=$(slurp)
[ -z "$GEOMETRY" ] && exit 0

notify-send "Gravacao" "Iniciada. Aperte o atalho de novo para parar."
wf-recorder -g "$GEOMETRY" -f "$FILE"
