#!/bin/bash

# 1. SETUP PATHS
CURRENT_USER=$(whoami)
USER_HOME=$HOME
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUDGIE_RICE_DIR="$REPO_DIR/rice/budgie"
AMOG_CONFIG="$USER_HOME/.config/amogos"
ASSETS_DIR="$USER_HOME/amogify/gui/assets"

# 2. SYSTEM DEPENDENCIES & ARC THEME
echo "[1/6] Requisitioning Gear..."
if command -v pacman &> /dev/null; then
    sudo pacman -S --noconfirm budgie-desktop budgie-control-center papirus-icon-theme fastfetch wget python
    ARC_FILE="arc-gtk-theme-20221218-2-any.pkg.tar.zst"
    ARC_URL="https://github.com/techtimefor/arc-theme-prebuilt/raw/refs/heads/main/$ARC_FILE"
    [ ! -f "$ARC_FILE" ] && wget -q -O "$ARC_FILE" "$ARC_URL"
    sudo pacman -U --noconfirm "$ARC_FILE"
elif command -v apt &> /dev/null; then
    sudo apt update && sudo apt install -y budgie-desktop papirus-icon-theme fastfetch wget arc-theme python3
elif command -v dnf &> /dev/null; then
    sudo dnf install -y budgie-desktop papirus-icon-theme fastfetch wget arc-theme python3
fi

# 3. ASSET DEPLOYMENT
echo "[2/6] Deploying assets..."
mkdir -p "$ASSETS_DIR" "$USER_HOME/amogify/rice/wallpapers" "$AMOG_CONFIG"
cp "$BUDGIE_RICE_DIR/amogus.webp" "$ASSETS_DIR/"
[ -f "$BUDGIE_RICE_DIR/Moon.png" ] && cp "$BUDGIE_RICE_DIR/Moon.png" "$USER_HOME/amogify/rice/wallpapers/"

# 4. FASTFETCH BRANDING
echo "[3/6] Configuring Fastfetch..."
cat <<'EOF' > "$AMOG_CONFIG/amogus_art.txt"
           ⣠⣤⣤⣤⣤⣤⣤⣤⣤⣄⡀
     ⢀⣴⣿⡿⠛⠉⠙⠛⠛⠛⠛⠻⢿⣿⣷⣤⡀
     ⣼⣿⠋⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⠈⢻⣿⣿⡄
    ⣸⣿⡏⠀⠀⠀⣠⣶⣾⣿⣿⣿⠿⠿⠿⢿⣿⣿⣿⣄
    ⣿⣿⠁⠀⠀⣿⣿⣯⠁⠀⠀⠀⠀⠀⠀⠀⠈⠙⢿⣷⡄
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

# 5. CREATE THE PYTHON RICE ENGINE
echo "[4/6] Creating Python Rice Engine..."
cat <<'EOF' > "$AMOG_CONFIG/apply_rice.py"
import os
import subprocess

home = os.path.expanduser("~")
rice_path = os.path.join(home, "amogify/rice/budgie")

def apply_rice(file_name, dconf_path):
    full_path = os.path.join(rice_path, file_name)
    if os.path.exists(full_path):
        with open(full_path, 'r') as f:
            content = f.read().replace("/home/deez", home)
        process = subprocess.Popen(['dconf', 'load', dconf_path], stdin=subprocess.PIPE, text=True)
        process.communicate(input=content)

apply_rice("amogos-budgie-desktop.txt", "/org/gnome/desktop/background/")
apply_rice("amogos-budgie-panel.txt", "/com/solus-project/budgie-panel/")
apply_rice("amogos-interface.txt", "/org/gnome/desktop/interface/")
EOF

# 6. CREATE THE SHELL SESSION WRAPPER
echo "[5/6] Creating Shell session wrapper..."
cat <<EOF > /tmp/amogos-session
#!/bin/bash
export XDG_CURRENT_DESKTOP=Budgie
export XDG_MENU_PREFIX=budgie-

# Run the Python rice engine to swap paths and apply theme
python3 "$AMOG_CONFIG/apply_rice.py"

# Launch the actual desktop
exec budgie-desktop
EOF

sudo mv /tmp/amogos-session /usr/local/bin/amogos-session
sudo chmod +x /usr/local/bin/amogos-session

# 7. REGISTER SESSION
echo "[6/6] Creating .desktop entry..."
cat <<EOF | sudo tee /usr/share/xsessions/amogos.desktop > /dev/null
[Desktop Entry]
Name=AmogOS
Comment=Among Us themed Budgie Desktop
Exec=/usr/local/bin/amogos-session
Type=Application
DesktopNames=Budgie
Icon=$ASSETS_DIR/amogus.webp
EOF

sudo chown -R $CURRENT_USER:$CURRENT_USER "$USER_HOME/amogify" "$AMOG_CONFIG"
echo "-------------------------------------------------------"
echo "INSTALL COMPLETE. Log out and select AmogOS."
echo "-------------------------------------------------------"
