#!/usr/bin/env bash
# Clima completo via wttr.in (JSON), reduzido pro que a aba Weather precisa.
raw=$(curl -s --max-time 6 "wttr.in/?format=j1" 2>/dev/null)

if [ -z "$raw" ]; then
    echo '{}'
    exit 0
fi

python3 - "$raw" <<'EOF'
import json, sys

try:
    d = json.loads(sys.argv[1])
except Exception:
    print("{}")
    sys.exit(0)

cur = d["current_condition"][0]
area = d["nearest_area"][0]
today = d["weather"][0]
astro = today["astronomy"][0]

days = []
for w in d["weather"]:
    days.append({
        "date": w["date"],
        "max": w["maxtempC"],
        "min": w["mintempC"],
        "desc": w["hourly"][4]["weatherDesc"][0]["value"],
    })

out = {
    "location": area["areaName"][0]["value"],
    "region": area["region"][0]["value"],
    "tempC": cur["temp_C"],
    "feelsLikeC": cur["FeelsLikeC"],
    "desc": cur["weatherDesc"][0]["value"],
    "humidity": cur["humidity"],
    "windKmph": cur["windspeedKmph"],
    "sunrise": astro["sunrise"],
    "sunset": astro["sunset"],
    "days": days,
}
print(json.dumps(out))
EOF
