#!/bin/bash

# 1. SETUP PATHS
CURRENT_USER=$(whoami)
USER_HOME=$HOME
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUDGIE_RICE_DIR="$REPO_DIR/rice/budgie"
ASSETS_DIR="$USER_HOME/amogify/gui/assets"
WALLPAPER_DIR="$USER_HOME/amogify/rice/wallpapers"
AMOG_CONFIG="$USER_HOME/.config/amogos"

# 2. SYSTEM DEPENDENCIES & ARC THEME BUILD
echo "[1/6] Requisitioning Gear (including Arc Theme)..."
if command -v pacman &> /dev/null; then
    # Arch Linux: Manual Arc Theme Download for compatibility
    sudo pacman -S --noconfirm budgie-desktop budgie-control-center papirus-icon-theme fastfetch wget
    ARC_FILE="arc-gtk-theme-20221218-2-any.pkg.tar.zst"
    ARC_URL="https://github.com/techtimefor/arc-theme-prebuilt/raw/refs/heads/main/$ARC_FILE"
    if [ ! -f "$ARC_FILE" ]; then
        wget -q -O "$ARC_FILE" "$ARC_URL"
    fi
    sudo pacman -U --noconfirm "$ARC_FILE"
elif command -v apt &> /dev/null; then
    # Debian / Ubuntu
    sudo apt update && sudo apt install -y budgie-desktop papirus-icon-theme fastfetch wget arc-theme
elif command -v dnf &> /dev/null; then
    # Fedora
    sudo dnf install -y budgie-desktop papirus-icon-theme fastfetch wget arc-theme
fi

# 3. ASSET DEPLOYMENT
echo "[2/6] Deploying assets..."
mkdir -p "$ASSETS_DIR" "$WALLPAPER_DIR" "$AMOG_CONFIG"
cp "$BUDGIE_RICE_DIR/amogus.webp" "$ASSETS_DIR/amogus.webp"
[ -f "$BUDGIE_RICE_DIR/Moon.png" ] && cp "$BUDGIE_RICE_DIR/Moon.png" "$WALLPAPER_DIR/Moon.png"

# 4. FASTFETCH BRANDING (ASCII & Config)
echo "[3/6] Configuring Fastfetch Branding..."
cat <<'EOF' > "$AMOG_CONFIG/amogus_art.txt"
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

cat <<EOF > "$AMOG_CONFIG/fastfetch.jsonc"
{
    "logo": { "source": "$AMOG_CONFIG/amogus_art.txt", "color": { "1": "red" } },
    "modules": [
        { "type": "title", "color": { "user": "red", "at": "white", "host": "blue" } },
        { "type": "custom", "format": "OS: AmogOS", "key": "OS" },
        "os", "kernel", "uptime", "packages", "shell", "de", "wm", "terminal", "cpu", "memory"
    ]
}
EOF

# 5. CREATE SESSION WRAPPER (Strictly Budgie)
echo "[4/6] Creating session wrapper..."
cat <<EOF > /tmp/amogos-session
#!/bin/bash
export XDG_CURRENT_DESKTOP=Budgie
export XDG_MENU_PREFIX=budgie-

# Set Alias for this session
alias fastfetch="fastfetch -c $AMOG_CONFIG/fastfetch.jsonc"
alias neofetch="fastfetch -c $AMOG_CONFIG/fastfetch.jsonc"

# Apply Rice Settings
sed "s|/home/deez|\$HOME|g" "$BUDGIE_RICE_DIR/amogos-budgie-desktop.txt" | dconf load /org/gnome/desktop/background/
sed "s|/home/deez|\$HOME|g" "$BUDGIE_RICE_DIR/amogos-budgie-panel.txt" | dconf load /com/solus-project/budgie-panel/
sed "s|/home/deez|\$HOME|g" "$BUDGIE_RICE_DIR/amogos-interface.txt" | dconf load /org/gnome/desktop/interface/

exec budgie-desktop
EOF

sudo mv /tmp/amogos-session /usr/local/bin/amogos-session
sudo chmod +x /usr/local/bin/amogos-session

# 6. REGISTER DESKTOP ENTRY
echo "[5/6] Creating .desktop entry..."
cat <<EOF | sudo tee /usr/share/xsessions/amogos.desktop > /dev/null
[Desktop Entry]
Name=AmogOS
Comment=Among Us themed Budgie Desktop
Exec=/usr/local/bin/amogos-session
Type=Application
DesktopNames=Budgie
Icon=$ASSETS_DIR/amogus.webp
EOF

# 7. CLEANUP & PERMISSIONS
sudo chown -R $CURRENT_USER:$CURRENT_USER "$USER_HOME/amogify" "$AMOG_CONFIG"
echo "[6/6] Finalizing..."

echo "-------------------------------------------------------"
echo "INSTALLATION COMPLETE."
echo "1. Log out."
echo "2. Select 'AmogOS' from your login screen."
echo "-------------------------------------------------------"
