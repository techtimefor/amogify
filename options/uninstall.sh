#!/bin/bash
echo "Ejecting the imposter..."

# 1. REMOVE SYSTEM SESSION FILES (Sudo required)
# This removes the entry from the login screen
if [ -f "/usr/share/xsessions/amogos.desktop" ]; then
    echo "Removing AmogOS session entry..."
    sudo rm -f /usr/share/xsessions/amogos.desktop
fi

# This removes the launch wrapper/logic
if [ -f "/usr/local/bin/amogos-session" ]; then
    echo "Removing session launch wrapper..."
    sudo rm -f /usr/local/bin/amogos-session
fi

# 2. CLEAN UP BASHRC (Aliases)
echo "Cleaning up shell aliases..."
# If we made a backup of bashrc during install, restore it
if [ -f "$HOME/.bashrc.bak" ]; then
    mv "$HOME/.bashrc.bak" "$HOME/.bashrc"
else
    # Otherwise, just scrub the specific aliases we added
    sed -i '/alias neofetch=/d' "$HOME/.bashrc"
    sed -i '/alias fastfetch=/d' "$HOME/.bashrc"
fi

# 3. WIPE ASSETS AND CONFIGS
echo "Removing AmogOS assets and configs..."
# Remove the custom assets folder
rm -rf "$HOME/amogify"

# Remove the fastfetch/branding configs
rm -rf "$HOME/.config/amogos"


# 4. REFRESH CACHE
if command -v update-desktop-database &> /dev/null; then
    sudo update-desktop-database
fi

echo "-------------------------------------------------------"
echo "System restored. The AmogOS session has been ejected."
echo "You may need to log out to see the session menu update."
echo "-------------------------------------------------------"
