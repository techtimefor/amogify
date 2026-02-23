#!/bin/bash

# 1. SETUP PATHS
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SYS_CONFIG="/usr/share/AmogOS-Config"
SKEL_BAK="/etc/skel.bak"

echo "-------------------------------------------------------"
echo "EXECUTING SYSTEM-WIDE AMOGOS DEPLOYMENT"
echo "-------------------------------------------------------"

# 2. SYSTEM BACKUP & GLOBAL ASSETS
echo "[1/8] Deploying Global Assets to /usr/share..."
if [ ! -d "$SKEL_BAK" ]; then sudo cp -r /etc/skel "$SKEL_BAK"; fi

sudo mkdir -p "$SYS_CONFIG/Wallpapers"
# Assuming your repo has a 'wallpapers' and 'rice' folder
sudo cp "$REPO_DIR/wallpapers/Moon.png" "$SYS_CONFIG/Wallpapers/Moon.png" 2>/dev/null
sudo cp -r "$REPO_DIR/rice" "$SYS_CONFIG/"

# 3. INSTALL DEPENDENCIES
echo "[2/8] Installing Dependencies..."
if command -v pacman &> /dev/null; then
    sudo pacman -S --noconfirm budgie-desktop xfce4 xfce4-goodies papirus-icon-theme fastfetch wget python
elif command -v apt &> /dev/null; then
    sudo apt update && sudo apt install -y budgie-desktop xfce4 xfce4-goodies papirus-icon-theme fastfetch wget arc-theme python3
fi

# 4. PATCHING CONFIGS FOR SYSTEM PATHS
echo "[3/8] Patching configs to point to /usr/share..."
sudo python3 - <<PYTHON_END
import os
sys_path = "/usr/share/AmogOS-Config"
# Patch all config files in the system directory
for root, dirs, files in os.walk(sys_path):
    for f_name in files:
        if f_name.endswith((".txt", ".xml", ".desktop", ".jsonc", ".rc", ".conf")):
            f_path = os.path.join(root, f_name)
            try:
                with open(f_path, 'r', encoding='utf-8') as f: content = f.read()
                # Replace home paths with the new system path
                new_content = content.replace("/home/deez", sys_path)
                new_content = new_content.replace("/home/amogos", sys_path)
                with open(f_path, 'w', encoding='utf-8') as f: f.write(new_content)
            except: pass
PYTHON_END

# 5. PREPARING /ETC/SKEL (The "Template")
echo "[4/8] Preparing /etc/skel for future users..."
sudo mkdir -p /etc/skel/.config/autostart
sudo mkdir -p /etc/skel/.config/amogos

# Create the Rice Initializer in Skel
sudo tee /etc/skel/.amogus-init.sh > /dev/null <<EOF
#!/bin/bash
sleep 2
if [[ "\$XDG_CURRENT_DESKTOP" == *"Budgie"* ]]; then
    dconf load /org/gnome/desktop/background/ < "$SYS_CONFIG/rice/budgie/amogos-budgie-desktop.txt"
    dconf load /com/solus-project/budgie-panel/ < "$SYS_CONFIG/rice/budgie/amogos-budgie-panel.txt"
    dconf load /org/gnome/desktop/interface/ < "$SYS_CONFIG/rice/budgie/amogos-interface.txt"
fi

if [[ "\$XDG_CURRENT_DESKTOP" == *"XFCE"* ]]; then
    mkdir -p \$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/
    cp "$SYS_CONFIG/rice/xfce/xfconf/"*.xml \$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/ 2>/dev/null
    mkdir -p \$HOME/.config/xfce4/desktop/
    cp "$SYS_CONFIG/rice/xfce/desktop/"*.rc \$HOME/.config/xfce4/desktop/ 2>/dev/null
    xfce4-panel -r && xfdesktop --reload
fi
rm -f \$HOME/.config/autostart/amogos-rice.desktop
EOF
sudo chmod +x /etc/skel/.amogus-init.sh

# Create the Autostart Entry in Skel
sudo tee /etc/skel/.config/autostart/amogos-rice.desktop > /dev/null <<EOF
[Desktop Entry]
Type=Application
Exec=bash \$HOME/.amogus-init.sh
Name=AmogOS-Rice
EOF

# 6. FASTFETCH SYSTEM-WIDE
echo "[5/8] Configuring Global Fastfetch..."
sudo tee "$SYS_CONFIG/fastfetch.jsonc" > /dev/null <<EOF
{
    "logo": { "source": "$SYS_CONFIG/rice/amogus_art.txt", "color": { "1": "red" } },
    "modules": [
        { "type": "title", "color": { "user": "red", "at": "white", "host": "blue" } },
        { "type": "custom", "format": "AmogOS", "key": "OS" },
        "os", "kernel", "uptime", "shell", "de", "wm", "terminal"
    ]
}
EOF

# Add Fastfetch to skel .bashrc
sudo tee -a /etc/skel/.bashrc > /dev/null <<EOF
alias fastfetch='fastfetch -c $SYS_CONFIG/fastfetch.jsonc'
alias neofetch='fastfetch -c $SYS_CONFIG/fastfetch.jsonc'
fastfetch
EOF

# 7. CREATE THE AMOGUS USER
echo "[6/8] Creating 'amogus' user (pulling from skel)..."
if ! id "amogus" &>/dev/null; then
    sudo useradd -m -s /bin/bash amogus
    echo "amogus:amogos" | sudo chpasswd
    sudo usermod -aG wheel amogus 2>/dev/null || sudo usermod -aG sudo amogus 2>/dev/null
fi

# 8. PERMISSIONS
echo "[7/8] Finalizing Global Permissions..."
sudo chmod -R 755 "$SYS_CONFIG"
sudo chown -R amogus:amogus "/home/amogus"

echo "-------------------------------------------------------"
echo "SYSTEM READY."
echo "Any user created from now on will have AmogOS defaults."
echo "Current Target: amogus | Pass: amogos"
echo "-------------------------------------------------------"
