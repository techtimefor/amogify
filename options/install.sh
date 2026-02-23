#!/bin/bash

# 1. SETUP PATHS
CURRENT_USER=$(whoami)
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AMOGUS_HOME="/home/amogus"
AMOG_CONFIG="$AMOGUS_HOME/.config/amogos"
SKEL_BAK="/etc/skel.bak"

echo "-------------------------------------------------------"
echo "Initializing AmogOS Deployment..."
echo "-------------------------------------------------------"

# 2. BACKUP /ETC/SKEL
echo "[1/8] Securing system skeleton..."
if [ ! -d "$SKEL_BAK" ]; then
    sudo cp -r /etc/skel "$SKEL_BAK"
    echo "Backup created at $SKEL_BAK"
else
    echo "Backup already exists. Skipping..."
fi

# 3. SYSTEM DEPENDENCIES
echo "[2/8] Requisitioning Gear (Budgie + XFCE)..."
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

# 4. CREATE AMOGUS USER
echo "[3/8] Creating 'amogus' user..."
if ! id "amogus" &>/dev/null; then
    sudo useradd -m -s /bin/bash amogus
    echo "amogus:amogos" | sudo chpasswd
    sudo usermod -aG wheel amogus 2>/dev/null || sudo usermod -aG sudo amogus 2>/dev/null
    echo "User created: amogus | Password: amogos"
else
    echo "User 'amogus' already exists."
fi

# 5. ASSET DEPLOYMENT
echo "[4/8] Deploying assets to /home/amogus..."
sudo mkdir -p "$AMOGUS_HOME/amogify" "$AMOG_CONFIG"
sudo cp -r "$REPO_DIR"/* "$AMOGUS_HOME/amogify/"

# 6. PYTHON PATH-SWAP ENGINE
echo "[5/8] Patching config files via Python..."
sudo python3 - <<PYTHON_END
import os

target_home = "/home/amogus"
base_dir = os.path.join(target_home, "amogify/rice")

for root, dirs, files in os.walk(base_dir):
    for f_name in files:
        if f_name.endswith((".txt", ".xml", ".desktop", ".jsonc")):
            f_path = os.path.join(root, f_name)
            try:
                with open(f_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                if "/home/deez" in content:
                    new_content = content.replace("/home/deez", target_home)
                    with open(f_path, 'w', encoding='utf-8') as f:
                        f.write(new_content)
            except Exception as e:
                pass
PYTHON_END

# 7. BRANDING (PERMISSION PATCHED)
echo "[6/8] Configuring Terminal & Auto-Rice..."

# Patching the 'Permission Denied' area by wrapping the write in a sudo sh call
sudo bash -c "cat <<'EOF' > $AMOG_CONFIG/amogus_art.txt
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
EOF"

# Permission-safe Fastfetch config
sudo bash -c "cat <<EOF > $AMOG_CONFIG/fastfetch.jsonc
{
    \"logo\": { \"source\": \"$AMOG_CONFIG/amogus_art.txt\", \"color\": { \"1\": \"red\" } },
    \"modules\": [
        { \"type\": \"title\", \"color\": { \"user\": \"red\", \"at\": \"white\", \"host\": \"blue\" } },
        { \"type\": \"custom\", \"format\": \"AmogOS\", \"key\": \"OS\" },
        \"os\",
        \"kernel\",
        \"uptime\",
        \"packages\",
        \"shell\",
        \"de\",
        \"wm\",
        \"terminal\",
        \"cpu\",
        \"memory\"
    ]
}
EOF"

# Create the login-run rice applier
sudo bash -c "cat <<EOF > $AMOGUS_HOME/.amogus-init.sh
#!/bin/bash
if [[ \"\$XDG_CURRENT_DESKTOP\" == *\"Budgie\"* ]]; then
    dconf load /org/gnome/desktop/background/ < \"$AMOGUS_HOME/amogify/rice/budgie/amogos-budgie-desktop.txt\"
    dconf load /com/solus-project/budgie-panel/ < \"$AMOGUS_HOME/amogify/rice/budgie/amogos-budgie-panel.txt\"
    dconf load /org/gnome/desktop/interface/ < \"$AMOGUS_HOME/amogify/rice/budgie/amogos-interface.txt\"
fi

if [[ \"\$XDG_CURRENT_DESKTOP\" == *\"XFCE\"* ]]; then
    mkdir -p \$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/
    cp \"$AMOGUS_HOME/amogify/rice/xfce/\"*.xml \$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/ 2>/dev/null
fi
sed -i '/.amogus-init.sh/d' \"\$HOME/.bashrc\"
EOF"
sudo chmod +x "$AMOGUS_HOME/.amogus-init.sh"

# 8. BASHRC INJECTION
echo "[7/8] Finalizing shell profile..."
sudo bash -c "cat <<EOF >> $AMOGUS_HOME/.bashrc

# AmogOS Initialization
if [ -f \"\$HOME/.amogus-init.sh\" ]; then
    bash \"\$HOME/.amogus-init.sh\"
fi

# Branding
alias fastfetch='fastfetch -c $AMOG_CONFIG/fastfetch.jsonc'
alias neofetch='fastfetch -c $AMOG_CONFIG/fastfetch.jsonc'
fastfetch
EOF"

# 9. PERMISSIONS
echo "[8/8] Cleaning up permissions..."
sudo chown -R amogus:amogus "$AMOGUS_HOME"

echo "-------------------------------------------------------"
echo "INSTALL COMPLETE."
echo "Login: amogus | Password: amogos"
echo "-------------------------------------------------------"
