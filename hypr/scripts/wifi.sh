#!/bin/bash
# Menu de wifi via Rofi + nmcli
# Lista redes disponiveis, conecta na escolhida (pede senha se necessario)

# Garante que o wifi esta ligado
nmcli radio wifi on

notify-send "Wi-Fi" "Buscando redes..."

# Lista as redes (SSID + sinal + seguranca), remove duplicatas e vazios
NETWORKS=$(nmcli --fields SSID,SIGNAL,SECURITY device wifi list | tail -n +2 | sort -k2 -nr | awk '!seen[$1]++' | grep -v '^--')

# Mostra no Rofi
CHOSEN=$(echo "$NETWORKS" | rofi -dmenu -p "Wi-Fi" -theme ~/.config/rofi/gruvbox.rasi)

# Se cancelou, sai
[ -z "$CHOSEN" ] && exit 0

# Extrai o SSID (primeira coluna)
SSID=$(echo "$CHOSEN" | awk '{print $1}')

# Verifica se ja tem conexao salva para essa rede
if nmcli connection show | grep -q "$SSID"; then
    nmcli connection up "$SSID" && notify-send "Wi-Fi" "Conectado a $SSID" || notify-send "Wi-Fi" "Falha ao conectar"
else
    # Rede nova: pede a senha via Rofi
    PASS=$(rofi -dmenu -password -p "Senha de $SSID" -theme ~/.config/rofi/gruvbox.rasi)
    if [ -z "$PASS" ]; then
        # tenta conectar sem senha (rede aberta)
        nmcli device wifi connect "$SSID" && notify-send "Wi-Fi" "Conectado a $SSID" || notify-send "Wi-Fi" "Falha ao conectar"
    else
        nmcli device wifi connect "$SSID" password "$PASS" && notify-send "Wi-Fi" "Conectado a $SSID" || notify-send "Wi-Fi" "Falha ao conectar"
    fi
fi
