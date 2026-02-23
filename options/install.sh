#!/bin/bash

# 1. AUTHENTICATION & PATH LOGIC
# logname ensures we get 'xubuntu' even if running under pkexec/root
REAL_USER=$(logname || echo $SUDO_USER || id -un)
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
AMOG_CONFIG="$REAL_HOME/.config/amogos"
RICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../rice" && pwd)"

echo "Fixing AmogOS for $REAL_USER..."

# 2. INSTALL DEPENDENCIES (Ubuntu Workaround)
# This handles the missing neofetch issue you mentioned
if command -v apt &> /dev/null; then
    apt update
    apt install -y arc-theme papirus-icon-theme plank xfce4-session lightdm
    # Try neofetch, fallback to fastfetch if neofetch is gone from repos
    apt install -y neofetch || apt install -y fastfetch
fi

# 3. DEPLOY & PATCH XML (Fixes the "empty" properties)
mkdir -p "$AMOG_CONFIG"
[ -d "$RICE_DIR/xfce4" ] && cp -r "$RICE_DIR/xfce4/." "$AMOG_CONFIG/"

DESKTOP_XML="$AMOG_CONFIG/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml"
if [ -f "$DESKTOP_XML" ]; then
    # Convert 'empty' to 'string' so the XDG script you found sees real data
    sed -i 's/type="empty"/type="string"/g' "$DESKTOP_XML"
    # Ensure the path to the Moon wallpaper is correct
    sed -i "s|name=\"image-path\" type=\"string\"/|name=\"image-path\" type=\"string\" value=\"$REAL_HOME/wallpapers/Moon.png\"/|g" "$DESKTOP_XML"
fi

# 4. THE SESSION FIX (Resolves all "Not Found" errors)
# We explicitly set HOME so the test logic you found doesn't guess /root/
mkdir -p /usr/share/xsessions
cat <<EOF > /usr/share/xsessions/amogos.desktop
[Desktop Entry]
Name=AmogOS
Comment=The most suspicious session
Exec=env HOME=$REAL_HOME XDG_CONFIG_HOME=$AMOG_CONFIG startxfce4
Type=Application
DesktopNames=XFCE
EOF

# 5. PERMISSIONS REPAIR
chown -R "$REAL_USER":"$REAL_USER" "$AMOG_CONFIG"
chown -R "$REAL_USER":"$REAL_USER" "$REAL_HOME/wallpapers"

echo "REPAIR COMPLETE. Logout and select 'AmogOS' from the session menu."
