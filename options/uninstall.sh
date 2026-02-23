#!/bin/bash
echo "Ejecting the imposter..."

# 1. RESTORE DCONF CONFIGURATION
BACKUP_PATH="$HOME/.config/amogos/backup_full.txt"

if [ -f "$BACKUP_PATH" ]; then
    echo "Restoring original desktop layout and theme..."
    # This force-loads your original snapshot back into dconf
    dconf load / < "$BACKUP_PATH"
    
    # Restart the panel live to revert the layout
    nohup budgie-panel --replace &>/dev/null &
else
    echo "Warning: No backup found at $BACKUP_PATH. UI cannot be auto-restored."
fi

# 2. CLEAN UP BASHRC (Aliases)
echo "Cleaning up shell aliases..."
if [ -f "$HOME/.bashrc.bak" ]; then
    mv "$HOME/.bashrc.bak" "$HOME/.bashrc"
else
    sed -i '/alias neofetch=/d' "$HOME/.bashrc"
    sed -i '/alias fastfetch=/d' "$HOME/.bashrc"
fi

# 3. WIPE AMOGOS FILES
echo "Removing AmogOS assets and configs..."
rm -rf "$HOME/amogify"
rm -rf "$HOME/.config/fastfetch/config.jsonc"

# We remove the config folder LAST so we don't delete the backup before loading it
rm -rf "$HOME/.config/amogos"

echo "System restored. You are no longer sus."
echo "Note: Some theme changes may require a logout to fully refresh."
