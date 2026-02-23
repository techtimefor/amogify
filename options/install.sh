#!/bin/bash

# 1. SETUP PATHS
CURRENT_USER=$(whoami)
USER_HOME=$HOME
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUDGIE_RICE_DIR="$REPO_DIR/rice/budgie"
AMOG_CONFIG="$USER_HOME/.config/amogos"
ASSETS_DIR="$USER_HOME/amogify/gui/assets"

# 2. SYSTEM DEPENDENCIES
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

# 5. RUN PYTHON PATH-SWAP (Now run BY this script)
echo "[4/6] Running Python Path-Swap Engine..."
python3 - <<PYTHON_END
import os

home = "$USER_HOME"
rice_dir = "$BUDGIE_RICE_DIR"
files = ["amogos-budgie-desktop.txt", "amogos-budgie-panel.txt", "amogos-interface.txt"]

for file_name in files:
    file_path = os.path.join(rice_dir, file_name)
    if os.path.exists(file_path):
        print(f"Amogifying {file_name}...")
        with open(file_path, 'r') as f:
            content = f.read()
        
        # Replace the dev path with the actual user home
        new_content = content.replace("/home/deez", home)
        
        with open(file_path, 'w') as f:
            f.write(new_content)
PYTHON_END

# 6. CREATE THE BASH SESSION WRAPPER
echo "[5/6] Creating Shell session wrapper..."
cat <<EOF > /tmp/amogos-session
#!/bin/bash
export XDG_CURRENT_DESKTOP=Budgie
export XDG_MENU_PREFIX=budgie-

# Since we already ran the Python swap, we just load the files directly
dconf load /org/gnome/desktop/background/ < "$BUDGIE_RICE_DIR/amogos-budgie-desktop.txt"
dconf load /com/solus-project/budgie-panel/ < "$BUDGIE_RICE_DIR/amogos-budgie-panel.txt"
dconf load /org/gnome/desktop/interface/ < "$BUDGIE_RICE_DIR/amogos-interface.txt"

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
echo "DONE. Python has finished the path-swap."
echo "Log out and select AmogOS."
echo "-------------------------------------------------------"
