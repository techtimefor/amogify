#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$DIR/utils/detect_distro.sh" ]; then
  . "$DIR/utils/detect_distro.sh"
else
  DISTRO=unknown
fi

detect_distro

run_gui() {
    if ! python3 -c "import PyQt6" &> /dev/null; then
        echo "PyQt6 not found. Installing dependencies..."
        if command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm python-pyqt6
        elif command -v apt &> /dev/null; then
            sudo apt update && sudo apt install -y python3-pyqt6
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y python3-pyqt6
        elif command -v zypper &> /dev/null; then
            sudo zypper install -y python3-PyQt6
        else
            echo "Error: Could not find a supported package manager. You are looking real sus right now."
            exit 1
        fi
    fi
    echo "Launching AmogOS GUI..."
    python3 "$DIR/gui/main.py"
    exit 0
}

show_menu() {
    SETUP=$(whiptail --title "Amogify CLI" --menu "Choose an option" 15 60 4 \
    "1" "Amogify" \
    "2" "Undo Amogify" \
    "3" "Support" \
    "4" "About" 3>&1 1>&2 2>&3)

    case $SETUP in
        1) . "$DIR/options/install.sh" ;;
        2) . "$DIR/options/uninstall.sh" ;;
        3) . "$DIR/options/support.sh" ;;
        4) . "$DIR/options/about.sh" ;;
        *) exit ;;
    esac

    echo ""
    read -p "Press Enter to return to menu..."
    show_menu
}

case "$1" in
    --cli) show_menu ;;
    --gui) run_gui ;;
    "")
        if [[ -n "$DISPLAY" || -n "$WAYLAND_DISPLAY" ]]; then
            run_gui
        else
            show_menu
        fi
        ;;
    *)
        echo "Invalid option: $1"
        echo "Valid options: --cli, --gui"
        exit 1
        ;;
esac


