#!/bin/bash

# 1. IDENTIFY REAL USER & HOME
# We avoid $HOME because pkexec sets it to /root
REAL_USER=$(logname || echo $SUDO_USER || id -un)
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
AMOG_CONFIG="$REAL_HOME/.config/amogos"
RICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../rice" && pwd)"

echo "Repairing AmogOS for $REAL_USER..."

# 2. DEPLOY ASSETS (Wallpapers must exist for the XML to work)
mkdir -p "$REAL_HOME/wallpapers"
[ -d "$RICE_DIR/wallpapers" ] && cp -r "$RICE_DIR/wallpapers/." "$REAL_HOME/wallpapers/"
chown -R "$REAL_USER":"$REAL_USER" "$REAL_HOME/wallpapers"

# 3. DEPLOY & PATCH XML (Fixes the "empty" types)
mkdir -p "$AMOG_CONFIG"
[ -d "$RICE_DIR/xfce4" ] && cp -r "$RICE_DIR/xfce4/." "$AMOG_CONFIG/"

DESKTOP_XML="$AMOG_CONFIG/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml"
if [ -f "$DESKTOP_XML" ]; then
    # Convert 'empty' to 'string' so XFCE recognizes the values
    sed -i 's/type="empty"/type="string"/g' "$DESKTOP_XML"
    # Inject the absolute path to the moon wallpaper
    sed -i "s|name=\"image-path\" type=\"string\"/|name=\"image-path\" type=\"string\" value=\"$REAL_HOME/wallpapers/Moon.png\"/|g" "$DESKTOP_XML"
    sed -i "s|name=\"last-image\" type=\"string\"/|name=\"last-image\" type=\"string\" value=\"$REAL_HOME/wallpapers/Moon.png\"/|g" "$DESKTOP_XML"
fi

# 4. CREATE THE SESSION FILE (The "Not Found" Fix)
# We explicitly set HOME and XDG_CONFIG_HOME so the logic you found works
mkdir -p /usr/share/xsessions
cat <<EOF > /usr/share/xsessions/amogos.desktop
[Desktop Entry]
Name=AmogOS
Comment=The most suspicious session
Exec=env HOME=$REAL_HOME XDG_CONFIG_HOME=$AMOG_CONFIG startxfce4
Type=Application
DesktopNames=XFCE
EOF

# 5. FINAL PERMISSIONS
chown -R "$REAL_USER":"$REAL_USER" "$AMOG_CONFIG"

echo "Success. LOG OUT and select AmogOS from the gear menu."
