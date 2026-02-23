#!/bin/bash
echo "Ejecting the imposter..."

# 1. REMOVE SESSION FILES (Sudo required)
# This removes the entry from the login screen (LightDM/GDM)
sudo rm -f /usr/share/xsessions/amogos.desktop

# This removes the launch wrapper we created to fix the "not found" error
sudo rm -f /usr/local/bin/amogos-session

# 2. RESTORE SYSTEM CONFIGS
if [ -f "/etc/lightdm/lightdm-gtk-greeter.conf.bak" ]; then
    echo "Restoring LightDM greeter..."
    sudo mv /etc/lightdm/lightdm-gtk-greeter.conf.bak /etc/lightdm/lightdm-gtk-greeter.conf
fi

# 3. CLEAN HOME FILES (No sudo needed)
echo "Cleaning user configuration..."
rm -rf "$HOME/.config/amogos"
rm -rf "$HOME/.config/fastfetch/amogus.txt"
rm -rf "$HOME/.config/fastfetch/config.jsonc"

# Restore backups
[ -f "$HOME/.face.bak" ] && mv "$HOME/.face.bak" "$HOME/.face"
if [ -f "$HOME/.bashrc.bak" ]; then
    mv "$HOME/.bashrc.bak" "$HOME/.bashrc"
else
    # If no backup, just remove the aliases we added
    sed -i '/alias neofetch=/d' "$HOME/.bashrc"
    sed -i '/alias fastfetch=/d' "$HOME/.bashrc"
fi

# 4. REFRESH SYSTEM
if command -v update-desktop-database &> /dev/null; then
    sudo update-desktop-database
fi

echo "System restored. You are no longer sus."
echo "Please reboot or restart LightDM to see changes."
