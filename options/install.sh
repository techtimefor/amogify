#!/bin/bash

# 1. PATH LOGIC
# We detect the user to ensure we don't create root-owned files in /home
CURRENT_USER=$(whoami)
USER_HOME=$HOME
AMOG_CONFIG="$USER_HOME/.config/amogos"
FF_CONFIG_DIR="$USER_HOME/.config/fastfetch"
NF_CONFIG_DIR="$AMOG_CONFIG/neofetch"
RICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../rice" && pwd)"
TEMPLATE_USER="amogos"

# Arc Theme for Arch (Manual download since it's off the official repos)
ARC_FILE="arc-gtk-theme-20221218-2-any.pkg.tar.zst"
ARC_URL="https://github.com/techtimefor/arc-theme-prebuilt/raw/refs/heads/main/arc-gtk-theme-20221218-2-any.pkg.tar.zst"

echo "[TASK 1/6] Backing up personal configurations..."
[ ! -f "$USER_HOME/.bashrc.bak" ] && cp "$USER_HOME/.bashrc" "$USER_HOME/.bashrc.bak"

echo "[TASK 2/6] Requisitioning Gear (Sudo for packages)..."
if command -v pacman &> /dev/null; then
    [ ! -f "$ARC_FILE" ] && wget -q -O "$ARC_FILE" "$ARC_URL"
    sudo pacman -U --noconfirm "$ARC_FILE"
    sudo pacman -S --noconfirm papirus-icon-theme plank neofetch fastfetch xfce4-session lightdm lightdm-gtk-greeter
elif command -v apt &> /dev/null; then
    sudo apt update && sudo apt install -y arc-theme papirus-icon-theme plank neofetch fastfetch xfce4-session lightdm
fi

echo "[TASK 3/6] Configuring Login Manager..."
if [ -f "$RICE_DIR/lightdm/lightdm-gtk-greeter.conf" ]; then
    sed "s|/home/$TEMPLATE_USER|/home/$CURRENT_USER|g" "$RICE_DIR/lightdm/lightdm-gtk-greeter.conf" > /tmp/amogos_greeter.conf
    sudo mkdir -p /etc/lightdm
    sudo mv /tmp/amogos_greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf
fi
sudo systemctl enable lightdm 2>/dev/null

echo "[TASK 4/6] Deploying Personal Assets..."
mkdir -p "$USER_HOME/wallpapers"
[ -d "$RICE_DIR/wallpapers" ] && cp -r "$RICE_DIR/wallpapers/." "$USER_HOME/wallpapers/"
[ -f "$RICE_DIR/.face" ] && cp "$RICE_DIR/.face" "$USER_HOME/.face"

echo "[TASK 5/6] Deploying Fetch Configs (Dual Support)..."
mkdir -p "$NF_CONFIG_DIR"
mkdir -p "$FF_CONFIG_DIR"
[ -d "$RICE_DIR/xfce4" ] && cp -r "$RICE_DIR/xfce4/." "$AMOG_CONFIG/"

# Path Sanitization
find "$AMOG_CONFIG" -type f -exec sed -i "s|/home/$TEMPLATE_USER|/home/$CURRENT_USER|g" {} +

# Common Imposter ASCII
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

# Fastfetch JSONC Config
cat <<EOF > "$FF_CONFIG_DIR/config.jsonc"
{
    "logo": { "source": "$AMOG_CONFIG/imposter.txt", "color": { "1": "red" } },
    "modules": [ "title", "os", "host", "kernel", "uptime", "packages", "shell", "de", "wm", "terminal", "cpu", "memory" ]
}
EOF

# Neofetch Config (Basic pointing to ASCII)
echo "image_source=\"$AMOG_CONFIG/imposter.txt\"" > "$NF_CONFIG_DIR/config.conf"
echo "ascii_distro=\"auto\"" >> "$NF_CONFIG_DIR/config.conf"

echo "[TASK 6/6] Establishing Session Wrapper..."
# Wrapper solves the LightDM 'Exec' parsing issue
cat <<EOF > /tmp/amogos-session
#!/bin/bash
export XDG_CONFIG_HOME="$AMOG_CONFIG"
exec startxfce4
EOF
sudo mv /tmp/amogos-session /usr/local/bin/amogos-session
sudo chmod +x /usr/local/bin/amogos-session

# Create Session Desktop File
sudo mkdir -p /usr/share/xsessions
cat <<EOF | sudo tee /usr/share/xsessions/amogos.desktop > /dev/null
[Desktop Entry]
Name=AmogOS
Exec=/usr/local/bin/amogos-session
Type=Application
DesktopNames=XFCE
EOF

# Fetch Aliases
if ! grep -q "neofetch --config" "$USER_HOME/.bashrc"; then
    echo "alias neofetch='fastfetch -c $FF_CONFIG_DIR/config.jsonc'" >> "$USER_HOME/.bashrc"
    echo "alias fastfetch='fastfetch -c $FF_CONFIG_DIR/config.jsonc'" >> "$USER_HOME/.bashrc"
fi

echo "MISSION SUCCESS. Logout and select AmogOS at the gear icon."
