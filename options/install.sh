#!/bin/bash

# 1. SETUP PATHS
CURRENT_USER=$(whoami)
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AMOGUS_HOME="/home/amogus"
AMOG_CONFIG="$AMOGUS_HOME/.config/amogos"
AUTOSTART_DIR="$AMOGUS_HOME/.config/autostart"
SKEL_BAK="/etc/skel.bak"

echo "-------------------------------------------------------"
echo "EXECUTING FULL AMOGOS DEPLOYMENT..."
echo "-------------------------------------------------------"

# 2. SYSTEM BACKUP (/etc/skel)
echo "[1/9] Backing up system skeleton..."
if [ ! -d "$SKEL_BAK" ]; then
    sudo cp -r /etc/skel "$SKEL_BAK"
    echo "Backup created at $SKEL_BAK"
fi

# 3. INSTALL DEPENDENCIES
echo "[2/9] Installing Environment (Budgie + XFCE)..."
if command -v pacman &> /dev/null; then
    sudo pacman -S --noconfirm budgie-desktop xfce4 xfce4-goodies papirus-icon-theme fastfetch wget python
    ARC_FILE="arc-gtk-theme-20221218-2-any.pkg.tar.zst"
    ARC_URL="https://github.com/techtimefor/arc-theme-prebuilt/raw/refs/heads/main/$ARC_FILE"
    [ ! -f "$ARC_FILE" ] && wget -q -O "$ARC_FILE" "$ARC_URL"
    sudo pacman -U --noconfirm "$ARC_FILE"
elif command -v apt &> /dev/null; then
    sudo apt update && sudo apt install -y budgie-desktop xfce4 xfce4-goodies papirus-icon-theme fastfetch wget arc-theme python3
elif command -v dnf &> /dev/null; then
    sudo dnf install -y budgie-desktop xfce4 xfce4-goodies papirus-icon-theme fastfetch wget arc-theme python3
fi

# 4. CREATE USER
echo "[3/9] Initializing 'amogus' user..."
if ! id "amogus" &>/dev/null; then
    sudo useradd -m -s /bin/bash amogus
    echo "amogus:amogos" | sudo chpasswd
    sudo usermod -aG wheel amogus 2>/dev/null || sudo usermod -aG sudo amogus 2>/dev/null
fi

# 5. DIRECTORY SETUP
sudo mkdir -p "$AMOG_CONFIG" "$AUTOSTART_DIR" "$AMOGUS_HOME/amogify"

# 6. ASSET DEPLOYMENT & PYTHON PATCHING
echo "[4/9] Deploying and Patching Rice Files..."
sudo cp -r "$REPO_DIR"/* "$AMOGUS_HOME/amogify/"

sudo python3 - <<PYTHON_END
import os
target_home = "/home/amogus"
base_dir = os.path.join(target_home, "amogify/rice")
for root, dirs, files in os.walk(base_dir):
    for f_name in files:
        if f_name.endswith((".txt", ".xml", ".desktop", ".jsonc")):
            f_path = os.path.join(root, f_name)
            try:
                with open(f_path, 'r', encoding='utf-8') as f: content = f.read()
                if "/home/deez" in content:
                    with open(f_path, 'w', encoding='utf-8') as f:
                        f.write(content.replace("/home/deez", target_home))
            except: pass
PYTHON_END

# 7. CREATE AUTOSTART RICE SCRIPT
echo "[5/9] Creating Autostart Logic..."
cat <<EOF > /tmp/amogus-rice.sh
#!/bin/bash
sleep 3
# Budgie Application
if [[ "\$XDG_CURRENT_DESKTOP" == *"Budgie"* ]]; then
    dconf load /org/gnome/desktop/background/ < "$AMOGUS_HOME/amogify/rice/budgie/amogos-budgie-desktop.txt"
    dconf load /com/solus-project/budgie-panel/ < "$AMOGUS_HOME/amogify/rice/budgie/amogos-budgie-panel.txt"
    dconf load /org/gnome/desktop/interface/ < "$AMOGUS_HOME/amogify/rice/budgie/amogos-interface.txt"
fi
# XFCE Application
if [[ "\$XDG_CURRENT_DESKTOP" == *"XFCE"* ]]; then
    mkdir -p \$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/
    cp "$AMOGUS_HOME/amogify/rice/xfce/"*.xml \$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/ 2>/dev/null
    xfce4-panel -r
fi
# Remove self so it only runs once
rm -f "$AUTOSTART_DIR/amogos-rice.desktop"
EOF
sudo mv /tmp/amogus-rice.sh "$AMOGUS_HOME/amogus-rice.sh"

# 8. CREATE AUTOSTART DESKTOP ENTRY
cat <<EOF > /tmp/amogos-rice.desktop
[Desktop Entry]
Type=Application
Exec=bash $AMOGUS_HOME/amogus-rice.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=AmogOS-Rice
EOF
sudo mv /tmp/amogos-rice.desktop "$AUTOSTART_DIR/amogos-rice.desktop"

# 9. FASTFETCH BRANDING
echo "[6/9] Branding Fastfetch..."
cat <<'EOF' > /tmp/amogus_art.txt
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
sudo mv /tmp/amogus_art.txt "$AMOG_CONFIG/amogus_art.txt"

cat <<EOF > /tmp/fastfetch.jsonc
{
    "logo": { "source": "$AMOG_CONFIG/amogus_art.txt", "color": { "1": "red" } },
    "modules": [
        { "type": "title", "color": { "user": "red", "at": "white", "host": "blue" } },
        { "type": "custom", "format": "AmogOS", "key": "OS" },
        "os", "kernel", "uptime", "packages", "shell", "de", "wm", "terminal", "cpu", "memory"
    ]
}
EOF
sudo mv /tmp/fastfetch.jsonc "$AMOG_CONFIG/fastfetch.jsonc"

# Final Shell Profile
sudo tee -a "$AMOGUS_HOME/.bashrc" > /dev/null <<EOF
alias fastfetch='fastfetch -c $AMOG_CONFIG/fastfetch.jsonc'
alias neofetch='fastfetch -c $AMOG_CONFIG/fastfetch.jsonc'
fastfetch
EOF

# 10. FINAL PERMISSIONS
echo "[7/9] Fixing ownership..."
sudo chown -R amogus:amogus "$AMOGUS_HOME"
sudo chmod -R 755 "$AMOGUS_HOME"
sudo chmod +x "$AMOGUS_HOME/amogus-rice.sh"

echo "-------------------------------------------------------"
echo "INSTALLATION SUCCESSFUL"
echo "User: amogus | Password: amogos"
echo "Log in as 'amogus' and wait 3s for the rice to apply."
echo "-------------------------------------------------------"
