#!/bin/bash
# AmogOS  Installer
# Run with: sudo ./install-amogos.sh

# 1. AUTHENTICATION & PATH LOGIC
if [ -n "$SUDO_USER" ]; then
    CURRENT_USER="$SUDO_USER"
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    CURRENT_USER=$(whoami)
    USER_HOME=$HOME
fi

# Configuration & Paths
TEMPLATE_USER="amogos"
AMOG_CONFIG="$USER_HOME/.config/amogos"
RICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../rice" && pwd)"
ARC_FILE="arc-gtk-theme-20221218-2-any.pkg.tar.zst"
ARC_URL="https://github.com/techtimefor/arc-theme-prebuilt/raw/refs/heads/main/arc-gtk-theme-20221218-2-any.pkg.tar.zst"

echo "[TASK 1/6] Safety Check: Backing up configurations..."
[ ! -f "$USER_HOME/.bashrc.bak" ] && cp "$USER_HOME/.bashrc" "$USER_HOME/.bashrc.bak" 2>/dev/null || true

if [ -f "/etc/lightdm/lightdm-gtk-greeter.conf" ] && [ ! -f "/etc/lightdm/lightdm-gtk-greeter.conf.bak" ]; then
    cp /etc/lightdm/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf.bak
fi

echo "[TASK 2/6] Requisitioning Gear..."
if command -v pacman &> /dev/null; then
    [ ! -f "$ARC_FILE" ] && wget -q -O "$ARC_FILE" "$ARC_URL"
    pacman -U --noconfirm "$ARC_FILE" 2>/dev/null || true
    pacman -S --noconfirm papirus-icon-theme plank screenfetch xfce4 xfce4-session lightdm lightdm-gtk-greeter
elif command -v apt &> /dev/null; then
    apt update
    apt install -y arc-theme papirus-icon-theme plank screenfetch xfce4 xfce4-session lightdm lightdm-gtk-greeter
fi

echo "[TASK 3/6] Configuring Login Manager..."
if [ -f "$RICE_DIR/lightdm/lightdm-gtk-greeter.conf" ]; then
    cp "$RICE_DIR/lightdm/lightdm-gtk-greeter.conf" /tmp/amogos_greeter.conf
    sed -i "s|/home/$TEMPLATE_USER|/home/$CURRENT_USER|g" /tmp/amogos_greeter.conf
    mkdir -p /etc/lightdm
    mv /tmp/amogos_greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf
fi
if command -v systemctl &> /dev/null; then
    systemctl enable lightdm --now 2>/dev/null || true
    systemctl set-default graphical.target
fi

echo "[TASK 4/6] Deploying Personal Assets..."
if [ -f "$RICE_DIR/.face" ]; then
    cp "$RICE_DIR/.face" "$USER_HOME/.face"
    chown "$CURRENT_USER":"$CURRENT_USER" "$USER_HOME/.face"
fi
mkdir -p "$USER_HOME/wallpapers"
if [ -d "$RICE_DIR/wallpapers" ]; then
    cp -r "$RICE_DIR/wallpapers/." "$USER_HOME/wallpapers/"
    chown -R "$CURRENT_USER":"$CURRENT_USER" "$USER_HOME/wallpapers"
fi

echo "[TASK 5/6] Deploying XFCE & AmogOS Screenfetch..."
mkdir -p "$AMOG_CONFIG"
if [ -d "$RICE_DIR/xfce4" ]; then
    cp -r "$RICE_DIR/xfce4" "$AMOG_CONFIG/"
fi

# THE MAGIC: Sanitize all home paths
find "$AMOG_CONFIG" -type f -exec sed -i "s|/home/$TEMPLATE_USER|/home/$CURRENT_USER|g" {} + 2>/dev/null || true

# XML PATCH for wallpaper
DESKTOP_XML="$AMOG_CONFIG/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml"
if [ -f "$DESKTOP_XML" ]; then
    echo "Applying deep XML patch..."
    sed -i 's/name="image-path" type="empty"/name="image-path" type="string" value="\/home\/'$CURRENT_USER'\/wallpapers\/Moon.png"/g' "$DESKTOP_XML"
    sed -i 's/name="last-image" type="empty"/name="last-image" type="string" value="\/home\/'$CURRENT_USER'\/wallpapers\/Moon.png"/g' "$DESKTOP_XML"
    sed -i 's/name="image-show" type="empty"/name="image-show" type="bool" value="true"/g' "$DESKTOP_XML"
fi

# === AMOGOS AMONG US ASCII (for screenfetch) ===
mkdir -p "$AMOG_CONFIG/screenfetch"
cat <<'EOF' > "$AMOG_CONFIG/screenfetch/amogos.ascii"
           ⣠⣤⣤⣤⣤⣤⣤⣤⣤⣄⡀
     ⢀⣴⣿⡿⠛⠉⠙⠛⠛⠛⠛⠻⢿⣿⣷⣤⡀
     ⣼⣿⠋⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⠈⢻⣿⣿⡄
    ⣸⣿⡏⠀⠀⠀⣠⣶⣾⣿⣿⣿⠿⠿⠿⢿⣿⣿⣿⣄
    ⣿⣿⠁⠀⠀⢰⣿⣿⣯⠁⠀⠀⠀⠀⠀⠀⠀⠈⠙⢿⣷⡄
 ⣀⣤⣴⣶⣶⣿⡟⠀⠀⠀⢸⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣷
⢰⣿⡟⠋⠉⣹⣿⡇⠀⠀⠀⠘⣿⣿⣿⣿⣷⣦⣤⣤⣤⣶⣶⣶⣶⣿⣿⣿
⢸⣿⡇⠀⠀⣿⣿⡇⠀⠀⠀⠀⠹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠃
⣸⣿⡇⠀⠀⣿⣿⡇⠀⠀⠀⠀⠀⠉⠻⠿⣿⣿⣿⣿⡿⠿⠿⠛⢻⣿⡇
⣿⣿⠁⠀⠀⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣧
⣿⣿⠀⠀⠀⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿
⣿⣿⠀⠀⠀⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿
⢿⣿⡆⠀⠀⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⡇
⠸⣿⣧⡀⠀⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠃
 ⠛⢿⣿⣿⣿⣿⣇⠀⠀⠀⠀⠀⣰⣿⣿⣷⣶⣶⣶⣶⠶⠀⢠⣿⣿
      ⣿⣿⠀⠀⠀⠀⠀⣿⣿⡇⠀⣽⣿⡏⠁⠀⠀⢸⣿⡇
      ⣿⣿⠀⠀⠀⠀⠀⣿⣿⡇⠀⢹⣿⡆⠀⠀⠀⣸⣿⠇
      ⢿⣿⣦⣄⣀⣠⣴⣿⣿⠁⠀⠈⠻⣿⣿⣿⣿⡿⠏
      ⠈⠛⠻⠿⠿⠿⠿⠋⠁
EOF

chown -R "$CURRENT_USER":"$CURRENT_USER" "$AMOG_CONFIG" 2>/dev/null || true

echo "[TASK 6/6] Establishing Session..."

# RELIABLE WRAPPER (same as before)
cat > /usr/local/bin/amogos-session << 'WRAPPER'
#!/bin/sh
export XDG_CONFIG_HOME="${HOME}/.config/amogos"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"
exec /usr/bin/startxfce4 "$@"
WRAPPER
chmod 755 /usr/local/bin/amogos-session

cat > /usr/share/xsessions/amogos.desktop << 'DESKTOP'
[Desktop Entry]
Name=AmogOS
Comment=Among Us Themed XFCE Desktop
Exec=/usr/local/bin/amogos-session
TryExec=/usr/local/bin/amogos-session
Type=Application
DESKTOP

# Screenfetch + AmogOS ASCII
if ! grep -q "amogos.ascii" "$USER_HOME/.bashrc"; then
    echo -e "\n# AmogOS Screenfetch with Among Us ASCII" >> "$USER_HOME/.bashrc"
    echo "alias screenfetch='cat \"$AMOG_CONFIG/screenfetch/amogos.ascii\"; screenfetch -n'" >> "$USER_HOME/.bashrc"
    echo "screenfetch" >> "$USER_HOME/.bashrc"   # auto-show on every new terminal
fi

echo "✅ MISSION SUCCESS!"
echo "Logout and select AmogOS at the login screen."
echo "The huge Among Us ASCII now appears with screenfetch in every terminal!"
