#!/bin/bash

# 1. AUTHENTICATION & PATH LOGIC
# Determine the actual user (even if run with sudo)
if [ -n "$SUDO_USER" ]; then
    CURRENT_USER="$SUDO_USER"
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    CURRENT_USER=$(whoami)
    USER_HOME=$HOME
fi

# Stop if running as pure root without SUDO_USER (prevents creating files in /root)
if [ "$CURRENT_USER" = "root" ] && [ "$USER_HOME" = "/root" ]; then
    echo "ERROR: Do not run this script directly as root. Use: sudo ./script.sh"
    exit 1
fi

# Configuration Variables
TEMPLATE_USER="amogos"
AMOG_CONFIG="$USER_HOME/.config/amogos"
RICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../rice" && pwd)"
ARC_FILE="/tmp/arc-gtk-theme.pkg.tar.zst" # Download to tmp to avoid permission issues
ARC_URL="https://github.com/techtimefor/arc-theme-prebuilt/raw/refs/heads/main/arc-gtk-theme-20221218-2-any.pkg.tar.zst"

# Helper function to run commands as the target user
run_as_user() {
    sudo -u "$CURRENT_USER" "$@"
}

echo "[TASK 1/6] Safety Check: Backing up configurations..."
# Backup as user to ensure user owns the backup
if [ -f "$USER_HOME/.bashrc" ]; then
    [ ! -f "$USER_HOME/.bashrc.bak" ] && run_as_user cp "$USER_HOME/.bashrc" "$USER_HOME/.bashrc.bak"
fi

if [ -f "/etc/lightdm/lightdm-gtk-greeter.conf" ] && [ ! -f "/etc/lightdm/lightdm-gtk-greeter.conf.bak" ]; then
    cp /etc/lightdm/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf.bak
fi

echo "[TASK 2/6] Requisitioning Gear..."
if command -v pacman &> /dev/null; then
    # Download to tmp
    [ ! -f "$ARC_FILE" ] && wget -q -O "$ARC_FILE" "$ARC_URL"
    pacman -U --noconfirm "$ARC_FILE"
    pacman -S --noconfirm papirus-icon-theme plank neofetch xfce4-session lightdm lightdm-gtk-greeter
elif command -v apt &> /dev/null; then
    apt update && apt install -y arc-theme papirus-icon-theme plank neofetch xfce4-session lightdm
fi

echo "[TASK 3/6] Configuring Login Manager..."
# Handle Greeter Config (System level, needs root)
if [ -f "$RICE_DIR/lightdm/lightdm-gtk-greeter.conf" ]; then
    cp "$RICE_DIR/lightdm/lightdm-gtk-greeter.conf" /tmp/amogos_greeter.conf
    sed -i "s|/home/$TEMPLATE_USER|/home/$CURRENT_USER|g" /tmp/amogos_greeter.conf
    mkdir -p /etc/lightdm
    mv /tmp/amogos_greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf
fi

if command -v systemctl &> /dev/null; then
    systemctl enable lightdm
    systemctl set-default graphical.target
fi

echo "[TASK 4/6] Deploying Personal Assets..."
# Create directories as USER
run_as_user mkdir -p "$USER_HOME/wallpapers"
run_as_user mkdir -p "$AMOG_CONFIG"

if [ -f "$RICE_DIR/.face" ]; then
    run_as_user cp "$RICE_DIR/.face" "$USER_HOME/.face"
fi

if [ -d "$RICE_DIR/wallpapers" ]; then
    run_as_user cp -r "$RICE_DIR/wallpapers/." "$USER_HOME/wallpapers/"
fi

echo "[TASK 5/6] Deploying XFCE & XML Patching..."
if [ -d "$RICE_DIR/xfce4" ]; then
    # Copy as user
    run_as_user cp -r "$RICE_DIR/xfce4" "$AMOG_CONFIG/"
fi

# Sanitize paths as user (Fixes the hardcoded template user issue)
run_as_user find "$AMOG_CONFIG" -type f -exec sed -i "s|/home/$TEMPLATE_USER|/home/$CURRENT_USER|g" {} +

# XML PATCH: Fixes the "type=empty" issue
DESKTOP_XML="$AMOG_CONFIG/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml"
if [ -f "$DESKTOP_XML" ]; then
    echo "Applying deep XML patch to $DESKTOP_XML..."
    # We use a temp file approach here because sed -i with sudo -u can be tricky with permissions on some distros
    # Extract current permissions
    chmod 666 "$DESKTOP_XML"
    
    sed -i 's/name="image-path" type="empty"/name="image-path" type="string" value="\/home\/'$CURRENT_USER'\/wallpapers\/Moon.png"/g' "$DESKTOP_XML"
    sed -i 's/name="last-image" type="empty"/name="last-image" type="string" value="\/home\/'$CURRENT_USER'\/wallpapers\/Moon.png"/g' "$DESKTOP_XML"
    sed -i 's/name="image-show" type="empty"/name="image-show" type="bool" value="true"/g' "$DESKTOP_XML"
    
    # Reset ownership
    chown "$CURRENT_USER":"$CURRENT_USER" "$DESKTOP_XML"
fi

# Neofetch ASCII art
run_as_user mkdir -p "$AMOG_CONFIG/neofetch"
# Using tee allows us to write to the file easily as root, then we chown
cat <<'EOF' > "$AMOG_CONFIG/neofetch/imposter.txt"
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
chown "$CURRENT_USER":"$CURRENT_USER" "$AMOG_CONFIG/neofetch/imposter.txt"

echo "[TASK 6/6] Establishing Session..."

# FIX FOR "UNABLE TO LAUNCH" ERROR:
# We create a wrapper script in /usr/local/bin. LightDM prefers this over complex 'env' lines in .desktop files.
SESSION_SCRIPT="/usr/local/bin/start-amogos-session"
cat <<EOF > "$SESSION_SCRIPT"
#!/bin/bash
# Set custom config home
export XDG_CONFIG_HOME="$AMOG_CONFIG"
# Ensure runtime dir exists (Fixes the XDG_RUNTIME_DIR error in your screenshot)
export XDG_RUNTIME_DIR=/run/user/\$(id -u)
mkdir -p "\$XDG_RUNTIME_DIR"
chmod 700 "\$XDG_RUNTIME_DIR"

# Start XFCE
exec startxfce4
EOF
chmod +x "$SESSION_SCRIPT"

# Create the Desktop Entry
mkdir -p /usr/share/xsessions
tee /usr/share/xsessions/amogos.desktop > /dev/null <<EOF
[Desktop Entry]
Name=AmogOS
Comment=The AmogOS Desktop Experience
Exec=/usr/local/bin/start-amogos-session
Type=Application
DesktopNames=AmogOS;XFCE
EOF

# Add neofetch alias to bashrc
if ! grep -q "neofetch --config" "$USER_HOME/.bashrc"; then
    echo -e "\nalias neofetch='neofetch --config $AMOG_CONFIG/neofetch/config.conf'" >> "$USER_HOME/.bashrc"
fi

# Final permission sweep to ensure everything is owned by the user
chown -R "$CURRENT_USER":"$CURRENT_USER" "$AMOG_CONFIG"
chown "$CURRENT_USER":"$CURRENT_USER" "$USER_HOME/.bashrc"

echo "MISSION SUCCESS. Logout and select AmogOS at the login screen."
