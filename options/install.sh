#!/bin/bash

# 1. SETUP PATHS
CURRENT_USER=$(whoami)
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUDGIE_RICE_DIR="$REPO_DIR/rice/budgie"

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

# 3. CREATE AMOGUS USER
echo "[2/6] Creating 'amogus' user..."
if ! id "amogus" &>/dev/null; then
    sudo useradd -m -s /bin/bash amogus
    echo "amogus:amogos" | sudo chpasswd
    # Add to sudoers so they aren't completely helpless
    sudo usermod -aG wheel amogus 2>/dev/null || sudo usermod -aG sudo amogus 2>/dev/null
else
    echo "User 'amogus' already exists."
fi

AMOGUS_HOME="/home/amogus"
AMOG_CONFIG="$AMOGUS_HOME/.config/amogos"

# 4. DEPLOY ASSETS & FASTFETCH BRANDING
echo "[3/6] Deploying Rice & Branding to amogus..."
sudo mkdir -p "$AMOGUS_HOME/amogify" "$AMOG_CONFIG"
sudo cp -r "$REPO_DIR"/* "$AMOGUS_HOME/amogify/"

# Create the Imposter ASCII art
sudo tee "$AMOG_CONFIG/amogus_art.txt" > /dev/null <<'EOF'
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

# Create the custom Fastfetch config
sudo tee "$AMOG_CONFIG/fastfetch.jsonc" > /dev/null <<EOF
{
    "logo": { "source": "$AMOG_CONFIG/amogus_art.txt", "color": { "1": "red" } },
    "modules": [
        { "type": "title", "color": { "user": "red", "at": "white", "host": "blue" } },
        { "type": "custom", "format": "OS: AmogOS", "key": "OS" },
        "os", "kernel", "uptime", "packages", "shell", "de", "wm", "terminal", "cpu", "memory"
    ]
}
EOF

# 5. RUN PYTHON PATH-SWAP
echo "[4/6] Running Python Path-Swap for amogus user..."
sudo python3 - <<PYTHON_END
import os

target_home = "/home/amogus"
rice_dir = os.path.join(target_home, "amogify/rice/budgie")
files = ["amogos-budgie-desktop.txt", "amogos-budgie-panel.txt", "amogos-interface.txt"]

for file_name in files:
    file_path = os.path.join(rice_dir, file_name)
    if os.path.exists(file_path):
        with open(file_path, 'r') as f:
            content = f.read()
        new_content = content.replace("/home/deez", target_home)
        with open(file_path, 'w') as f:
            f.write(new_content)
PYTHON_END

# 6. INJECT TERMINAL AUTO-START (Fastfetch on launch)
echo "[5/6] Setting up persistent Fastfetch in amogus .bashrc..."
sudo tee -a "$AMOGUS_HOME/.bashrc" > /dev/null <<EOF

# AmogOS Branding
alias fastfetch='fastfetch -c $AMOG_CONFIG/fastfetch.jsonc'
alias neofetch='fastfetch -c $AMOG_CONFIG/fastfetch.jsonc'
fastfetch
EOF

# 7. APPLY DCONF & PERMISSIONS
echo "[6/6] Finalizing AmogOS Profile..."
sudo -u amogus dbus-launch dconf load /org/gnome/desktop/background/ < "$AMOGUS_HOME/amogify/rice/budgie/amogos-budgie-desktop.txt"
sudo -u amogus dbus-launch dconf load /com/solus-project/budgie-panel/ < "$AMOGUS_HOME/amogify/rice/budgie/amogos-budgie-panel.txt"
sudo -u amogus dbus-launch dconf load /org/gnome/desktop/interface/ < "$AMOGUS_HOME/amogify/rice/budgie/amogos-interface.txt"

sudo chown -R amogus:amogus "$AMOGUS_HOME"

echo "-------------------------------------------------------"
echo "INSTALL COMPLETE."
echo "User: amogus | Password: amogos"
echo "Log out and enter the Skeld as 'amogus'."
echo "-------------------------------------------------------"
