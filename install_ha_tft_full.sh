#!/bin/bash

set -e

LOG_DIR="$HOME/tft_kiosk_logs"
mkdir -p "$LOG_DIR"

echo "==== 1️⃣ Update systeem en installeer basispakketten ===="
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl build-essential cmake libboost-dev libdrm-dev libbsd-dev libjpeg-dev \
xinput-calibrator x11-xserver-utils matchbox-window-manager chromium xserver-xorg xinit evtest

echo "==== 2️⃣ Docker installeren ===="
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

echo "==== 3️⃣ Home Assistant container installeren ===="
mkdir -p $HOME/homeassistant
docker run -d --name homeassistant --privileged --restart unless-stopped \
  -e TZ=Europe/Amsterdam \
  -v $HOME/homeassistant:/config \
  --network host \
  ghcr.io/home-assistant/home-assistant:stable

echo "==== 4️⃣ fbcp-ili9341 TFT installeren ===="
cd $HOME
git clone https://github.com/juj/fbcp-ili9341.git
cd fbcp-ili9341
mkdir build && cd build
cmake ..
make -j4
sudo make install

echo "==== 5️⃣ Systemd service voor TFT aanmaken ===="
sudo bash -c 'cat <<EOF > /etc/systemd/system/fbcp.service
[Unit]
Description=FrameBuffer Copy for ILI9341
After=network.target

[Service]
ExecStart='"$HOME"'/fbcp-ili9341/build/fbcp-ili9341 --width=320 --height=240 >> '"$LOG_DIR"'/fbcp.log 2>&1
Restart=always
User='"$USER"'

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl daemon-reload
sudo systemctl enable fbcp
sudo systemctl start fbcp

echo "==== 6️⃣ Chromium kiosk autostart configureren ===="
mkdir -p $HOME/.xinitrc
cat <<'EOL' > $HOME/.xinitrc
#!/bin/bash
LOG_FILE="$HOME/tft_kiosk_logs/chromium.log"
matchbox-window-manager >> "$LOG_FILE" 2>&1 &

# Wacht tot Home Assistant bereikbaar is
HOST="http://localhost:8123"
echo "Wachten tot Home Assistant start..." >> "$LOG_FILE"
while ! curl -s --connect-timeout 2 $HOST >/dev/null; do
    sleep 2
done

# Start Chromium in kiosk mode
chromium --noerrdialogs --disable-infobars --kiosk $HOST >> "$LOG_FILE" 2>&1
EOL
chmod +x $HOME/.xinitrc

echo "==== 7️⃣ XPT2046 touch automatisch kalibreren ===="
TOUCH_DEVICE=$(ls /dev/input/by-id/*XPT2046* 2>/dev/null | head -n1)
if [ -n "$TOUCH_DEVICE" ]; then
    echo "Touchscreen gevonden: $TOUCH_DEVICE"
    DISPLAY=:0 xinput_calibrator --device "$TOUCH_DEVICE" --output-type xorg >> "$LOG_DIR"/touch.log 2>&1
    echo "Touch automatisch gekalibreerd!"
else
    echo "Geen XPT2046 touchscreen gevonden. Controleer verbinding."
fi

echo "==== 8️⃣ systemd service voor autostart van Xorg (Chromium kiosk) ===="
sudo bash -c 'cat <<EOF > /etc/systemd/system/xorg-kiosk.service
[Unit]
Description=Start Xorg + Chromium Kiosk
After=graphical.target
Requires=graphical.target

[Service]
User='"$USER"'
Environment=DISPLAY=:0
ExecStart=/usr/bin/startx >> '"$LOG_DIR"'/xorg.log 2>&1
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl daemon-reload
sudo systemctl enable xorg-kiosk

echo "==== Installatie compleet! ===="
echo "Home Assistant is bereikbaar via: http://<IP-van-Pi>:8123"
echo "Alle logs staan in $LOG_DIR (fbcp.log, chromium.log, xorg.log, touch.log)"
echo "Herstart Pi om alles automatisch te laten starten:"
echo "sudo reboot"
