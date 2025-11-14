# home-assistant-tft-setup
my setup x pi4 and homeassistant
# Home Assistant TFT Headless Setup for Raspberry Pi

**Beschrijving:**  
Deze repository bevat scripts om een Raspberry Pi volledig headless te configureren met:

- **Home Assistant** in Docker  
- **3.5" SPI TFT display (ILI9341/fbcp-ili9341)**  
- **XPT2046 touchscreen**  
- **Chromium in kiosk mode** om HA te tonen  
- **Automatische touch-calibratie**  
- **Live log dashboard via SSH**  

Alles wordt automatisch gestart bij boot, geen scherm of toetsenbord nodig.

---

## Bestanden

- `install_ha_tft_full.sh` – Installatie en setup van Pi, TFT, touch en Home Assistant.  
- `tft_logs_dashboard_color.sh` – Live log dashboard met kleurcodering voor TFT, Chromium, Xorg en touch.  
- `README.md` – Deze uitleg.  

---

## Voorbereiding SD-kaart

1. Download **Raspberry Pi OS 64-bit met Desktop**:  
   [https://www.raspberrypi.com/software/](https://www.raspberrypi.com/software/)  

2. Flash de SD-kaart via **Raspberry Pi Imager**.  

3. Activeer **SSH** en configureer Wi-Fi via Advanced Options:  
   - Stel **gebruikersnaam + wachtwoord** in  
   - SSID + wachtwoord voor Wi-Fi  
   - Tijdszone instellen (Europe/Amsterdam)  

4. Plaats SD-kaart in de Pi en start op.

---

## Installatie

1. SSH naar de Pi:

```bash
ssh <gebruikersnaam>@<IP-van-Pi>
