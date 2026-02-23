#!/bin/bash

# 1. FORCE-GET REAL USER (Bypasses the 'root' bug)
REAL_USER=$(logname || echo $SUDO_USER || id -un $LOGNAME)
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

# Configuration & Paths
AMOG_CONFIG="$REAL_HOME/.config/amogos"
RICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../rice" && pwd)"

echo "Repairing AmogOS for User: $REAL_USER"

# 2. PATCH XML (Fixes image_7f6541.png)
# This converts 'empty' tags to valid 'string' tags so XFCE sees the wallpaper
DESKTOP_XML="$AMOG_CONFIG/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml"
if [ -d "$RICE_DIR/xfce4" ]; then
    mkdir -p "$(dirname "$DESKTOP_XML")"
    cp -r "$RICE_DIR/xfce4/." "$AMOG_CONFIG/"
fi

if [ -f "$DESKTOP_XML" ]; then
    echo "Applying deep XML patch..."
    sed -i "s|type=\"empty\"|type=\"string\"|g" "$DESKTOP_XML"
    # Inject correct path to the Moon wallpaper
    sed -i "s|name=\"image-path\" type=\"string\"/|name=\"image-path\" type=\"string\" value=\"$REAL_HOME/wallpapers/Moon.png\"/|g" "$DESKTOP_XML"
fi

# 3. CREATE THE CORRECT SESSION FILE (Fixes image_8df489.png)
# We use the REAL_HOME path here so it never points to /root/
mkdir -p /usr/share/xsessions
cat <<EOF > /usr/share/xsessions/amogos.desktop
[Desktop Entry]
Name=AmogOS
Comment=The most suspicious session
Exec=env XDG_CONFIG_HOME=$AMOG_CONFIG startxfce4
Type=Application
EOF

# 4. FIX PERMISSIONS
chown -R "$REAL_USER":"$REAL_USER" "$AMOG_CONFIG"
echo "Fix complete."
