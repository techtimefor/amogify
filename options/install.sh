#!/bin/bash

# 1. FORCE-GET REAL USER (Avoids the 'root' bug)
# Using logname or id -un is more reliable than $USER in pkexec
REAL_USER=$(logname || echo $SUDO_USER || id -un $LOGNAME)
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

# Configuration & Paths
AMOG_CONFIG="$REAL_HOME/.config/amogos"
RICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../rice" && pwd)"

echo "Targeting User: $REAL_USER"
echo "Targeting Home: $REAL_HOME"

# 2. CLEANUP OLD BROKEN SESSION (Resolves image_8df489.png)
echo "[TASK 1/3] Purging old root session..."
rm -f /usr/share/xsessions/amogos.desktop

# 3. INSTALLING DEPENDENCIES (Ubuntu Neofetch fix)
echo "[TASK 2/3] Installing packages..."
if command -v apt &> /dev/null; then
    apt update
    apt install -y arc-theme papirus-icon-theme plank xfce4-session lightdm
    # Try neofetch, fallback to fastfetch if missing
    apt install -y neofetch || apt install -y fastfetch
fi

# 4. DEPLOY AND PATCH XML (Fixes image_7f6541.png)
echo "[TASK 3/3] Deploying configs..."
mkdir -p "$AMOG_CONFIG"
[ -d "$RICE_DIR/xfce4" ] && cp -r "$RICE_DIR/xfce4" "$AMOG_CONFIG/"

# Patch the XML to replace "empty" with real paths
DESKTOP_XML="$AMOG_CONFIG/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml"
if [ -f "$DESKTOP_XML" ]; then
    sed -i "s|type=\"empty\"|type=\"string\"|g" "$DESKTOP_XML"
    # Force the wallpaper path
    sed -i "s|name=\"image-path\" type=\"string\"/|name=\"image-path\" type=\"string\" value=\"$REAL_HOME/wallpapers/Moon.png\"/|g" "$DESKTOP_XML"
fi

# 5. CREATE FRESH SESSION FILE
cat <<EOF > /usr/share/xsessions/amogos.desktop
[Desktop Entry]
Name=AmogOS
Comment=The most suspicious session
Exec=env XDG_CONFIG_HOME=$AMOG_CONFIG startxfce4
Type=Application
EOF

# Fix permissions
chown -R "$REAL_USER":"$REAL_USER" "$AMOG_CONFIG"
chown -R "$REAL_USER":"$REAL_USER" "$REAL_HOME/wallpapers"

echo "DONE. Restart your computer and look for 'AmogOS' in the login menu."
