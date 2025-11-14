#!/bin/bash

LOG_DIR="$HOME/tft_kiosk_logs"

# Maak logbestanden aan als ze niet bestaan
for f in fbcp.log chromium.log xorg.log touch.log; do
    [ ! -f "$LOG_DIR/$f" ] && touch "$LOG_DIR/$f"
done

# Kleuren
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
NC="\033[0m" # Geen kleur

echo -e "${YELLOW}==== TFT Kiosk Live Dashboard ====${NC}"
echo "Ctrl+C om te stoppen"

# Start parallelle tail's met kleurprefix
tail -f "$LOG_DIR/fbcp.log"    2>/dev/null | while read l; do echo -e "${RED}[fbcp]${NC} $l"; done &
TAIL_FB_PID=$!
tail -f "$LOG_DIR/chromium.log" 2>/dev/null | while read l; do echo -e "${GREEN}[chromium]${NC} $l"; done &
TAIL_CR_PID=$!
tail -f "$LOG_DIR/xorg.log"     2>/dev/null | while read l; do echo -e "${BLUE}[xorg]${NC} $l"; done &
TAIL_XO_PID=$!
tail -f "$LOG_DIR/touch.log"    2>/dev/null | while read l; do echo -e "${YELLOW}[touch]${NC} $l"; done &
TAIL_TCH_PID=$!

# Trap Ctrl+C om alle tail's te stoppen
trap "kill $TAIL_FB_PID $TAIL_CR_PID $TAIL_XO_PID $TAIL_TCH_PID; exit" INT

wait
