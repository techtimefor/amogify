#!/bin/bash
echo "Ejecting the imposter..."

# 1. REMOVE THE DEDICATED USER
# This wipes the user, their home directory (/home/amogus), and their mail spool.
if id "amogus" &>/dev/null; then
    echo "Removing 'amogus' user and all associated data..."
    sudo userdel -r amogus
else
    echo "User 'amogus' not found. Skipping..."
fi

# 2. REMOVE SYSTEM SESSION FILES (Legacy Cleanup)
# In case the old version was installed, we clean these up too.
echo "Cleaning up any legacy system files..."
sudo rm -f /usr/share/xsessions/amogos.desktop
sudo rm -f /usr/local/bin/amogos-session

# 3. CLEAN UP CURRENT USER BASHRC (If modified)
echo "Cleaning up current user shell aliases..."
if [ -f "$HOME/.bashrc.bak" ]; then
    mv "$HOME/.bashrc.bak" "$HOME/.bashrc"
else
    sed -i '/alias neofetch=/d' "$HOME/.bashrc"
    sed -i '/alias fastfetch=/d' "$HOME/.bashrc"
    # Remove the autostart fastfetch call if it exists
    sed -i '/fastfetch -c.*amogos/d' "$HOME/.bashrc"
fi

# 4. WIPE LOCAL CONFIGS
rm -rf "$HOME/.config/amogos"

# 5. REFRESH SESSION DATABASE
if command -v update-desktop-database &> /dev/null; then
    sudo update-desktop-database
fi

echo "-------------------------------------------------------"
echo "MISSION OVER. The AmogOS user has been ejected."
echo "The system is now clean."
echo "-------------------------------------------------------"
