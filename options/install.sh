#!/bin/bash

# 1. SIMPLE PATHS
CURRENT_USER=$(whoami)
USER_HOME=$HOME
AMOG_CONFIG="$USER_HOME/.config/amogos"
FF_CONFIG_DIR="$USER_HOME/.config/fastfetch"
NF_CONFIG_DIR="$AMOG_CONFIG/neofetch"
RICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../rice" && pwd)"
TEMPLATE_USER="amogos"

# Arc Theme for Arch
ARC_FILE="arc-gtk-theme-20221218-2-any.pkg.tar.zst"
ARC_URL="https://github.com/techtimefor/arc-theme-prebuilt/raw/refs/heads/main/arc-gtk-theme-20221218-2-any.pkg.tar.zst"

echo "[TASK 1/6] Requisitioning Gear..."
if command -v pacman &> /dev/null; then
    [ ! -f "$ARC_FILE" ] && wget -q -O "$ARC_FILE" "$ARC_URL"
    sudo pacman -U --noconfirm "$ARC_FILE"
    sudo pacman -S --noconfirm papirus-icon-theme plank neofetch fastfetch xfce4-session lightdm
elif command -v apt &> /dev/null; then
    sudo apt update
    sudo apt install -y arc-theme papirus-icon-theme plank fastfetch xfce4-session lightdm
fi

echo "[TASK 2/6] Deploying Configs & Theme..."
mkdir -p "$AMOG_CONFIG/autostart"
mkdir -p "$FF_CONFIG_DIR"
mkdir -p "$NF_CONFIG_DIR"
[ -d "$RICE_DIR/xfce4" ] && cp -r "$RICE_DIR/xfce4/." "$AMOG_CONFIG/"

# Path Sanitization
find "$AMOG_CONFIG" -type f -exec sed -i "s|/home/$TEMPLATE_USER|/home/$CURRENT_USER|g" {} +

# ENFORCE ARC-DARK
XFSET_DIR="$AMOG_CONFIG/xfce4/xfconf/xfce-perchannel-xml"
mkdir -p "$XFSET_DIR"
cat <<EOF > "$XFSET_DIR/xsettings.xml"
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="Arc-Dark"/>
    <property name="IconThemeName" type="string" value="Papirus-Dark"/>
  </property>
</channel>
EOF

echo "[TASK 3/6] Configuring Autostart (Plank + Terminal)..."
# Start Plank
cat <<EOF > "$AMOG_CONFIG/autostart/plank.desktop"
[Desktop Entry]
Type=Application
Exec=plank
Name=Plank
EOF

# Start Terminal on Login
cat <<EOF > "$AMOG_CONFIG/autostart/xfce4-terminal.desktop"
[Desktop Entry]
Type=Application
Exec=xfce4-terminal -e "bash -c 'fastfetch; exec bash'"
Name=Terminal
EOF

# Pin Essentials to Plank
PLANK_LAUNCHERS="$USER_HOME/.config/plank/dock1/launchers"
mkdir -p "$PLANK_LAUNCHERS"
rm -f "$PLANK_LAUNCHERS"/*.dockitem
apps=("xfce4-terminal" "thunar" "firefox")
for i in "${!apps[@]}"; do
    cat <<EOF > "$PLANK_LAUNCHERS/item${i}.dockitem"
[PlankDockItemPreferences]
Launcher=file:///usr/share/applications/${apps[$i]}.desktop
EOF
done

echo "[TASK 4/6] Setting up Fetch (AmogOS Branding)..."
cat <<'EOF' > "$AMOG_CONFIG/imposter.txt"
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

cat <<EOF > "$FF_CONFIG_DIR/config.jsonc"
{
    "logo": { "source": "$AMOG_CONFIG/imposter.txt", "color": { "1": "red" } },
    "modules": [
        { "type": "title", "color": { "user": "red", "at": "white", "host": "blue" } },
        { "type": "custom", "format": "OS: AmogOS", "key": "OS" },
        "os", "host", "kernel", "uptime", "packages", "shell", "de", "wm", "terminal", "cpu", "memory", "colors"
    ]
}
EOF
[ -x "$(command -v neofetch)" ] && echo "image_source=\"$AMOG_CONFIG/imposter.txt\"" > "$NF_CONFIG_DIR/config.conf"

echo "[TASK 5/6] Establishing Session & Neon Wallpaper..."
# Copy Neon wallpaper to a reliable path
mkdir -p "$USER_HOME/wallpapers"
cp "$RICE_DIR/wallpapers/Neon.png" "$USER_HOME/wallpapers/Neon.png"

# Force wallpaper in XFCE XML
DESKTOP_XML="$XFSET_DIR/xfce4-desktop.xml"
cat <<EOF > "$DESKTOP_XML"
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitor0" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="$USER_HOME/wallpapers/Neon.png"/>
        </property>
      </property>
    </property>
  </property>
</channel>
EOF

cat <<EOF > /tmp/amogos-session
#!/bin/bash
export XDG_CONFIG_HOME="$AMOG_CONFIG"
exec startxfce4
EOF
sudo mv /tmp/amogos-session /usr/local/bin/amogos-session
sudo chmod +x /usr/local/bin/amogos-session

sudo mkdir -p /usr/share/xsessions
cat <<EOF | sudo tee /usr/share/xsessions/amogos.desktop > /dev/null
[Desktop Entry]
Name=AmogOS
Exec=/usr/local/bin/amogos-session
Type=Application
DesktopNames=XFCE
EOF

echo "[TASK 6/6] Finalizing Permissions..."
sudo chown -R $CURRENT_USER:$CURRENT_USER "$USER_HOME/.config"
sudo chown -R $CURRENT_USER:$CURRENT_USER "$USER_HOME/wallpapers"

# Aliases
if ! grep -q "alias neofetch=" "$USER_HOME/.bashrc"; then
    echo "alias neofetch='fastfetch -c $FF_CONFIG_DIR/config.jsonc'" >> "$USER_HOME/.bashrc"
    echo "alias fastfetch='fastfetch -c $FF_CONFIG_DIR/config.jsonc'" >> "$USER_HOME/.bashrc"
fi

echo "MISSION SUCCESS. Neon wallpaper set and Terminal will autostart."
