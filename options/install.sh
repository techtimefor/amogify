#!/bin/bash

# 1. AUTHENTICATION & PATH LOGIC
# When running via pkexec/sudo, we must target the real user's home
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
[ ! -f "$USER_HOME/.bashrc.bak" ] && cp "$USER_HOME/.bashrc" "$USER_HOME/.bashrc.bak"
if [ -f "/etc/lightdm/lightdm-gtk-greeter.conf" ] && [ ! -f "/etc/lightdm/lightdm-gtk-greeter.conf.bak" ]; then
    cp /etc/lightdm/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf.bak
fi

echo "[TASK 2/6] Requisitioning Gear (Distro-Specific)..."
if command -v pacman &> /dev/null; then
    [ ! -f "$ARC_FILE" ] && wget -q -O "$ARC_FILE" "$ARC_URL"
    pacman -U --noconfirm "$ARC_FILE"
    pacman -S --noconfirm papirus-icon-theme plank neofetch xfce4-session lightdm lightdm-gtk-greeter
elif command -v apt &> /dev/null; then
    apt update && apt install -y arc-theme papirus-icon-theme plank neofetch xfce4-session lightdm
elif command -v dnf &> /dev/null; then
    dnf install -y arc-theme papirus-icon-theme plank neofetch xfce4-session lightdm
fi

echo "[TASK 3/6] Configuring Login Manager (Greeter)..."
if [ -f "$RICE_DIR/lightdm/lightdm-gtk-greeter.conf" ]; then
    # Sanitize and move greeter config
    cp "$RICE_DIR/lightdm/lightdm-gtk-greeter.conf" /tmp/amogos_greeter.conf
    sed -i "s|/home/$TEMPLATE_USER|/home/$CURRENT_USER|g" /tmp/amogos_greeter.conf
    mkdir -p /etc/lightdm
    mv /tmp/amogos_greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf
fi

if command -v systemctl &> /dev/null; then
    systemctl enable lightdm
    systemctl set-default graphical.target
fi

echo "[TASK 4/6] Deploying Personal Assets (.face & Wallpapers)..."
# Apply .face avatar directly to home root
if [ -f "$RICE_DIR/.face" ]; then
    [ -f "$USER_HOME/.face" ] && [ ! -L "$USER_HOME/.face" ] && mv "$USER_HOME/.face" "$USER_HOME/.face.bak"
    cp "$RICE_DIR/.face" "$USER_HOME/.face"
    chown "$CURRENT_USER":"$CURRENT_USER" "$USER_HOME/.face"
fi

# Deploy Wallpapers
mkdir -p "$USER_HOME/wallpapers"
if [ -d "$RICE_DIR/wallpapers" ]; then
    cp -r "$RICE_DIR/wallpapers/." "$USER_HOME/wallpapers/"
    chown -R "$CURRENT_USER":"$CURRENT_USER" "$USER_HOME/wallpapers"
fi

echo "[TASK 5/6] Deploying XFCE & Neofetch Configs..."
mkdir -p "$AMOG_CONFIG/neofetch"
if [ -d "$RICE_DIR/xfce4" ]; then
    cp -r "$RICE_DIR/xfce4" "$AMOG_CONFIG/"
fi
if [ -f "$RICE_DIR/config.conf" ]; then
    cp "$RICE_DIR/config.conf" "$AMOG_CONFIG/neofetch/config.conf"
fi

# THE MAGIC: Sanitize all home paths
find "$AMOG_CONFIG" -type f -exec sed -i "s|/home/$TEMPLATE_USER|/home/$CURRENT_USER|g" {} +

# PATCH: Force correct wallpaper in xfce4-desktop.xml
DESKTOP_XML="$AMOG_CONFIG/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml"
if [ -f "$DESKTOP_XML" ]; then
    echo "Applying wallpaper patch to $DESKTOP_XML..."
    # Replace the incorrect /usr/share path with the local Moon.png path
    sed -i "s|/usr/share/wallpapers/AmogOS-Wallpapers/neon.png|/home/$CURRENT_USER/wallpapers/Moon.png|g" "$DESKTOP_XML"
    sed -i "s|last-image\" type=\"string\" value=\"[^\"]*\"|last-image\" type=\"string\" value=\"/home/$CURRENT_USER/wallpapers/Moon.png\"|g" "$DESKTOP_XML"
fi

# Create ASCII art
cat <<'EOF' > "$AMOG_CONFIG/neofetch/imposter.txt"
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

# Reset ownership to user
chown -R "$CURRENT_USER":"$CURRENT_USER" "$AMOG_CONFIG"

echo "[TASK 6/6] Establishing Session & Aliases..."
mkdir -p /usr/share/xsessions
tee /usr/share/xsessions/amogos.desktop > /dev/null <<EOF
[Desktop Entry]
Name=AmogOS
Comment=The most suspicious session
Exec=env XDG_CONFIG_HOME=$AMOG_CONFIG startxfce4
Type=Application
DesktopNames=XFCE
EOF

if ! grep -q "neofetch --config" "$USER_HOME/.bashrc"; then
    echo -e "\nalias neofetch='neofetch --config $AMOG_CONFIG/neofetch/config.conf'" >> "$USER_HOME/.bashrc"
fi

echo "MISSION SUCCESS. Logout and select AmogOS at the login screen."