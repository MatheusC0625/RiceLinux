#!/usr/bin/env bash
# Métricas de desempenho: CPU, GPU, memória, armazenamento e rede.
# Faz duas amostras com um pequeno intervalo pra calcular taxas (uso de CPU/rede).

read_stat() {
    awk '/^cpu /{print $2+$3+$4+$5+$6+$7+$8, $5}' /proc/stat
}
read_net() {
    awk '$1!="Inter-|" && $1!="face" && NF>=10 {
        iface=$1; sub(":","",iface);
        if (iface != "lo") { rx+=$2; tx+=$10 }
    } END { print rx, tx }' /proc/net/dev
}

read -r cpu1_total cpu1_idle <<< "$(read_stat)"
read -r net1_rx net1_tx <<< "$(read_net)"
t1=$(date +%s.%N)

sleep 0.4

read -r cpu2_total cpu2_idle <<< "$(read_stat)"
read -r net2_rx net2_tx <<< "$(read_net)"
t2=$(date +%s.%N)

cpu_pct=$(awk -v t1="$cpu1_total" -v i1="$cpu1_idle" -v t2="$cpu2_total" -v i2="$cpu2_idle" \
    'BEGIN { dt=t2-t1; di=i2-i1; if (dt<=0) print 0; else printf "%.0f", (1 - di/dt) * 100 }')

dt=$(awk -v a="$t1" -v b="$t2" 'BEGIN { print b - a }')
rx_rate=$(awk -v a="$net1_rx" -v b="$net2_rx" -v dt="$dt" 'BEGIN { printf "%.0f", (b-a)/dt }')
tx_rate=$(awk -v a="$net1_tx" -v b="$net2_tx" -v dt="$dt" 'BEGIN { printf "%.0f", (b-a)/dt }')

cpu_temp=$(cat /sys/class/hwmon/hwmon5/temp1_input 2>/dev/null || echo 0)
gpu_pct=$(cat /sys/class/drm/card0/device/gpu_busy_percent 2>/dev/null || echo 0)
gpu_temp=$(cat /sys/class/hwmon/hwmon3/temp1_input 2>/dev/null || echo 0)

mem=$(LC_ALL=C free -b | awk '/^Mem:/{print $2, $3}')
disk=$(LC_ALL=C df -B1 / | awk 'NR==2{print $2, $3}')

cpu_model=$(awk -F': ' '/model name/{print $2; exit}' /proc/cpuinfo)
gpu_model=$(lspci 2>/dev/null | grep -iE "vga|3d" | head -1 | sed -E 's/.*: //')

python3 - "$cpu_pct" "$cpu_temp" "$gpu_pct" "$gpu_temp" "$mem" "$disk" "$rx_rate" "$tx_rate" "$cpu_model" "$gpu_model" <<'EOF'
import json, re, sys

cpu_pct, cpu_temp, gpu_pct, gpu_temp = sys.argv[1:5]
mem_total, mem_used = sys.argv[5].split()
disk_total, disk_used = sys.argv[6].split()
rx, tx = sys.argv[7], sys.argv[8]
cpu_model, gpu_model = sys.argv[9], sys.argv[10]

# nomes curtos: tira boilerplate de fabricante/revisão
cpu_model = re.sub(r"\s*with Radeon Graphics", "", cpu_model).strip()
gpu_model = re.sub(r"^.*?\[(.*?)\]\s*", r"\1 ", gpu_model)
gpu_model = re.sub(r"\s*\(rev [0-9a-f]+\)", "", gpu_model).strip()

print(json.dumps({
    "cpu": {"model": cpu_model, "usage": int(cpu_pct), "tempC": round(int(cpu_temp) / 1000, 1)},
    "gpu": {"model": gpu_model, "usage": int(gpu_pct), "tempC": round(int(gpu_temp) / 1000, 1)},
    "mem": {"totalGiB": round(int(mem_total) / 2**30, 1), "usedGiB": round(int(mem_used) / 2**30, 1)},
    "disk": {"totalGiB": round(int(disk_total) / 2**30, 1), "usedGiB": round(int(disk_used) / 2**30, 1)},
    "net": {"rxBps": int(rx), "txBps": int(tx)},
}))
EOF
