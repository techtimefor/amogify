#!/bin/bash

# 1. GET THE REAL USER (Crucial fix for image_8df489.png)
# logname ignores the 'root' identity of pkexec and finds 'xubuntu'
REAL_USER=$(logname || echo $SUDO_USER || id -un)
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
AMOG_CONFIG="$REAL_HOME/.config/amogos"
RICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../rice" && pwd)"

# 2. PATCH THE XML (Fixes the "empty" types issue)
mkdir -p "$AMOG_CONFIG"
if [ -d "$RICE_DIR/xfce4" ]; then
    cp -r "$RICE_DIR/xfce4/." "$AMOG_CONFIG/"
fi

DESKTOP_XML="$AMOG_CONFIG/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml"
if [ -f "$DESKTOP_XML" ]; then
    # Changes 'empty' to 'string' so XFCE recognizes the values
    sed -i 's/type="empty"/type="string"/g' "$DESKTOP_XML"
    sed -i "s|name=\"image-path\" type=\"string\"/|name=\"image-path\" type=\"string\" value=\"$REAL_HOME/wallpapers/Moon.png\"/|g" "$DESKTOP_XML"
fi

# 3. CREATE THE SESSION FILE WITH CORRECT PATHS
mkdir -p /usr/share/xsessions
cat <<EOF > /usr/share/xsessions/amogos.desktop
[Desktop Entry]
Name=AmogOS
Comment=The most suspicious session
Exec=env HOME=$REAL_HOME XDG_CONFIG_HOME=$AMOG_CONFIG startxfce4
Type=Application
EOF

chown -R "$REAL_USER":"$REAL_USER" "$AMOG_CONFIG"
echo "Fix Applied. Log out and select AmogOS."
