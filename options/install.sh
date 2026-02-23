#!/bin/bash

# 1. PATHS & GLOBAL VARIABLES
CURRENT_USER=$(whoami)
USER_HOME=$HOME
AMOG_CONFIG="$USER_HOME/.config/amogos"
FF_CONFIG_DIR="$USER_HOME/.config/fastfetch"
# Location of your budgie folder relative to this script
BUDGIE_RICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../rice/budgie" && pwd)"
ASSETS_DIR="$USER_HOME/amogify/gui/assets"
WALLPAPER_DIR="$USER_HOME/amogify/rice/wallpapers"
BACKUP_PATH="$AMOG_CONFIG/backup_full.txt"

# Safety Check: Ensure the script isn't run as root/sudo globally
if [ "$EUID" -eq 0 ]; then 
  echo "ERROR: Please do not run this script with sudo."
  echo "The script will ask for your password only when installing packages."
  exit 1
fi

echo "      AMOGOS BUDGIE INSTALLER           "

# 2. TASK 1: INSTALL DEPENDENCIES (Needs Sudo)
echo "[TASK 1/5] Requisitioning Gear..."
if command -v pacman &> /dev/null; then
    # Arch Linux
    sudo pacman -S --noconfirm budgie-desktop budgie-control-center papirus-icon-theme fastfetch wget
    ARC_FILE="arc-gtk-theme-20221218-2-any.pkg.tar.zst"
    ARC_URL="https://github.com/techtimefor/arc-theme-prebuilt/raw/refs/heads/main/$ARC_FILE"
    [ ! -f "$ARC_FILE" ] && wget -q -O "$ARC_FILE" "$ARC_URL"
    sudo pacman -U --noconfirm "$ARC_FILE"
elif command -v apt &> /dev/null; then
    # Debian / Ubuntu / Mint
    sudo apt update && sudo apt install -y budgie-desktop papirus-icon-theme fastfetch wget arc-theme
elif command -v dnf &> /dev/null; then
    # Fedora
    sudo dnf install -y budgie-desktop papirus-icon-theme fastfetch wget arc-theme
fi

# 3. TASK 2: LIVE SYSTEM BACKUP (No Sudo)
echo "[TASK 2/5] Creating full system backup at $BACKUP_PATH..."
mkdir -p "$AMOG_CONFIG"
# Snapshot the entire dconf database. This is your "Undo" button.
dconf dump / > "$BACKUP_PATH"

# 4. TASK 3: DEPLOY RICE ASSETS (No Sudo)
echo "[TASK 3/5] Moving rice assets to local storage..."
mkdir -p "$ASSETS_DIR" "$WALLPAPER_DIR" "$FF_CONFIG_DIR"

# Copy Amogus Menu Icon
if [ -f "$BUDGIE_RICE_DIR/amogus.webp" ]; then
    cp "$BUDGIE_RICE_DIR/amogus.webp" "$ASSETS_DIR/amogus.webp"
fi

# Copy Moon Wallpaper (rename to Moon.png if it was neon.png)
if [ -f "$BUDGIE_RICE_DIR/Moon.png" ]; then
    cp "$BUDGIE_RICE_DIR/Moon.png" "$WALLPAPER_DIR/Moon.png"
elif [ -f "$BUDGIE_RICE_DIR/../wallpapers/neon.png" ]; then
    cp "$BUDGIE_RICE_DIR/../wallpapers/neon.png" "$WALLPAPER_DIR/Moon.png"
fi

# 5. TASK 4: FASTFETCH BRANDING (No Sudo)
echo "[TASK 4/5] Setting up Imposter Fetch..."
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

# Update shell aliases
grep -q "alias fastfetch=" "$USER_HOME/.bashrc" || echo "alias fastfetch='fastfetch -c $FF_CONFIG_DIR/config.jsonc'" >> "$USER_HOME/.bashrc"
grep -q "alias neofetch=" "$USER_HOME/.bashrc" || echo "alias neofetch='fastfetch -c $FF_CONFIG_DIR/config.jsonc'" >> "$USER_HOME/.bashrc"

# 6. TASK 5: APPLY DCONF SETTINGS (No Sudo)
echo "[TASK 5/5] Patching username and applying styling..."

# Apply the three core rice files, replacing 'deez' with your actual username
sed "s|/home/deez|$USER_HOME|g" "$BUDGIE_RICE_DIR/amogos-budgie-desktop.txt" | dconf load /org/gnome/desktop/background/
sed "s|/home/deez|$USER_HOME|g" "$BUDGIE_RICE_DIR/amogos-budgie-panel.txt" | dconf load /com/solus-project/budgie-panel/
sed "s|/home/deez|$USER_HOME|g" "$BUDGIE_RICE_DIR/amogos-interface.txt" | dconf load /org/gnome/desktop/interface/

# Finalize permissions and refresh UI
nohup budgie-panel --replace &>/dev/null &

echo "INSTALLATION COMPLETE."
echo "Your original settings were backed up to: $BACKUP_PATH"
