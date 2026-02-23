#!/bin/bash

# 1. PATHS & VARIABLES
CURRENT_USER=$(whoami)
USER_HOME=$HOME
AMOG_CONFIG="$USER_HOME/.config/amogos"
FF_CONFIG_DIR="$USER_HOME/.config/fastfetch"
# Adjusted to your current folder structure
BUDGIE_RICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../rice/budgie" && pwd)"
ASSETS_DIR="$USER_HOME/amogify/gui/assets"
WALLPAPER_DIR="$USER_HOME/amogify/rice/wallpapers"

echo "[TASK 1/5] Requisitioning Gear (Multi-Distro Support)..."

if command -v pacman &> /dev/null; then
    # ARCH
    ARC_FILE="arc-gtk-theme-20221218-2-any.pkg.tar.zst"
    ARC_URL="https://github.com/techtimefor/arc-theme-prebuilt/raw/refs/heads/main/arc-gtk-theme-20221218-2-any.pkg.tar.zst"
    sudo pacman -S --noconfirm budgie-desktop budgie-control-center papirus-icon-theme fastfetch wget
    [ ! -f "$ARC_FILE" ] && wget -q -O "$ARC_FILE" "$ARC_URL"
    sudo pacman -U --noconfirm "$ARC_FILE"

elif command -v apt &> /dev/null; then
    # DEBIAN / UBUNTU
    sudo apt update
    sudo apt install -y budgie-desktop papirus-icon-theme fastfetch wget arc-theme

elif command -v dnf &> /dev/null; then
    # FEDORA
    sudo dnf install -y budgie-desktop papirus-icon-theme fastfetch wget arc-theme
fi

echo "[TASK 2/5] Deploying Assets (Fixing Paths)..."
mkdir -p "$FF_CONFIG_DIR" "$ASSETS_DIR" "$WALLPAPER_DIR" "$AMOG_CONFIG"

# Match the exact path from your dconf dump: /home/deez/amogify/rice/wallpapers/Moon.png
if [ -f "$BUDGIE_RICE_DIR/Moon.png" ]; then
    cp "$BUDGIE_RICE_DIR/Moon.png" "$WALLPAPER_DIR/Moon.png"
else
    # Fallback if Moon.png is named neon.png in your rice folder
    cp "$BUDGIE_RICE_DIR/../wallpapers/neon.png" "$WALLPAPER_DIR/Moon.png"
fi
cp "$BUDGIE_RICE_DIR/amogus.webp" "$ASSETS_DIR/amogus.webp"

echo "[TASK 3/5] Setting up Fastfetch Branding..."
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

echo "[TASK 4/5] Establishing Isolated Budgie Session..."
# This script is what the Login Manager actually runs
cat <<EOF > /tmp/amogos-session
#!/bin/bash
# 1. Environment Variables (Required to keep session alive)
export XDG_CURRENT_DESKTOP=Budgie:GNOME
export XDG_MENU_PREFIX=budgie-

# 2. Dynamic Config Loading
# Path translation from 'deez' to current user
sed "s|/home/deez|/home/\$USER|g" "$BUDGIE_RICE_DIR/amogos-budgie-desktop.txt" | dconf load /org/gnome/desktop/background/
sed "s|/home/deez|/home/\$USER|g" "$BUDGIE_RICE_DIR/amogos-budgie-panel.txt" | dconf load /com/solus-project/budgie-panel/
sed "s|/home/deez|/home/\$USER|g" "$BUDGIE_RICE_DIR/amogos-interface.txt" | dconf load /org/gnome/desktop/interface/

# 3. Launch Budgie
exec budgie-desktop
EOF

sudo mv /tmp/amogos-session /usr/local/bin/amogos-session
sudo chmod +x /usr/local/bin/amogos-session

# Create the Login Manager entry
sudo mkdir -p /usr/share/xsessions
cat <<EOF | sudo tee /usr/share/xsessions/amogos.desktop > /dev/null
[Desktop Entry]
Name=AmogOS (Budgie)
Comment=Amogus-themed Budgie Desktop
Exec=/usr/local/bin/amogos-session
Type=Application
DesktopNames=Budgie:GNOME
EOF

echo "[TASK 5/5] Shell Configuration..."
# Fastfetch aliases
if ! grep -q "alias fastfetch=" "$USER_HOME/.bashrc"; then
    echo "alias fastfetch='fastfetch -c $FF_CONFIG_DIR/config.jsonc'" >> "$USER_HOME/.bashrc"
    echo "alias neofetch='fastfetch -c $FF_CONFIG_DIR/config.jsonc'" >> "$USER_HOME/.bashrc"
fi

# Fix permissions for the current user
sudo chown -R $CURRENT_USER:$CURRENT_USER "$USER_HOME/amogify" "$USER_HOME/.config"

echo "MISSION SUCCESS. Log out and select 'AmogOS (Budgie)' from your login screen."
