#!/bin/bash
if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    USER_HOME=$HOME
fi

echo "Ejecting the imposter..."

# Restore system configs
sudo rm -f /usr/share/xsessions/amogos.desktop
[ -f "/etc/lightdm/lightdm-gtk-greeter.conf.bak" ] && sudo mv /etc/lightdm/lightdm-gtk-greeter.conf.bak /etc/lightdm/lightdm-gtk-greeter.conf

# Clean home files
rm -rf "$HOME/.config/amogos"
[ -f "$HOME/.face.bak" ] && mv "$HOME/.face.bak" "$HOME/.face"
[ -f "$HOME/.bashrc.bak" ] && mv "$HOME/.bashrc.bak" "$HOME/.bashrc"

echo "System restored. You are no longer sus."