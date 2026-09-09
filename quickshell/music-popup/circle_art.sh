#!/usr/bin/env bash
# Baixa/copia a capa do álbum e gera uma versão recortada em círculo, cacheada por hash da URL.
# Uso: circle_art.sh <url_ou_caminho> <pasta_de_cache> [tamanho_px]
# Imprime o caminho do PNG resultante em stdout.

set -e
src="$1"
cache_dir="$2"
size="${3:-200}"

mkdir -p "$cache_dir"

hash=$(printf '%s' "$src" | md5sum | cut -d' ' -f1)
dest="$cache_dir/$hash.png"

if [ -f "$dest" ]; then
    echo "$dest"
    exit 0
fi

tmp=$(mktemp --suffix=.img)
trap 'rm -f "$tmp"' EXIT

if [[ "$src" == http://* || "$src" == https://* ]]; then
    curl -fsSL --max-time 5 "$src" -o "$tmp" || exit 1
elif [[ "$src" == file://* ]]; then
    cp "${src#file://}" "$tmp"
else
    cp "$src" "$tmp"
fi

half=$((size / 2))

convert "$tmp" -resize "${size}x${size}^" -gravity center -extent "${size}x${size}" \
    \( -size "${size}x${size}" xc:black -fill white -draw "circle ${half},${half} ${half},0" \) \
    -alpha off -compose CopyOpacity -composite "$dest"

echo "$dest"
