#!/bin/bash
set -euo pipefail

# 3D Migoto URL
MIGOTO_URL="https://github.com/bo3b/3Dmigoto/releases/download/1.3.16/3Dmigoto-1.3.16.zip"
# Installation dir
AC_DIR="/home/deck/.local/share/Steam/steamapps/common/ACE COMBAT 7/"
# Scripts directory
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
# Proton prefix location for AC7 (used to map an extra drive letter)
PFX_DIR="/home/deck/.local/share/Steam/steamapps/compatdata/502500/pfx"
DOSDEV_DIR="${PFX_DIR}/dosdevices"

# Cleanup to run on exit (success or failure)
cleanup() {
    set +e
    # Remove drive mapping
    if [ -L "${DOSDEV_DIR}/g:" ]; then
        rm -f "${DOSDEV_DIR}/g:"
    fi
    # Remove downloaded archives if they exist
    [ -f "${AC_DIR}Steamless.zip" ] && rm -f "${AC_DIR}Steamless.zip"
    [ -f "${AC_DIR}3Dmigoto-1.3.16.zip" ] && rm -f "${AC_DIR}3Dmigoto-1.3.16.zip"
    # Remove temporary Steamless folder if it exists
    [ -d "${AC_DIR}Steamless" ] && rm -rf "${AC_DIR}Steamless"
}
trap cleanup EXIT

# Function to display success message in green
function success_message() {
    echo -e "\e[1;32m$1\e[0m"
}

# Function to display failure message in red
function failure_message() {
    echo -e "\e[1;31m$1\e[0m"
}

# Function to display info message in yellow
function info_message() {
    echo -e "\e[1;33m$1\e[0m"
}

# Function to display instruction message in blue
function instruction_message() {
    echo -e "\e[1;34m$1\e[0m"
}

info_message "Checking if protontricks is installed"

# Install protontricks via flatpak if not installed
if ! flatpak list | grep -q com.github.Matoking.protontricks; then
    info_message "Protontricks not found. Installing via flatpak..."
    flatpak install -y com.github.Matoking.protontricks

    if [ $? -eq 0 ]; then
        success_message "Protontricks installed successfully."
    else
        failure_message "Failed to install Protontricks via flatpak."
        
        # Try to run protontricks -v to see if it's already available
        info_message "Attempting to verify if protontricks is already installed..."
        if protontricks -V &> /dev/null; then
            success_message "Protontricks is already installed and functioning."
        else
            failure_message "Protontricks installation failed and could not verify an existing installation. Exiting."
            exit 1
        fi
    fi
else
    success_message "Protontricks is already installed."
fi


info_message "Moving mod files to game directory"
# Move Mods, ShaderFixes, and resolution_patch.py to AC_DIR using rsync
for ITEM in "Mods" "ShaderFixes" "resolution_patch.py"; do
    if [ -e "$SCRIPT_DIR/$ITEM" ]; then
        rsync -a "$SCRIPT_DIR/$ITEM" "$AC_DIR"
        if [ $? -eq 0 ]; then
            :
        else
            failure_message "Failed to move $ITEM to $AC_DIR."
        fi
    else
        info_message "$ITEM not found in $SCRIPT_DIR. Skipping."
    fi
done

info_message "Downloading 3Dmigoto"
# Download 3D Migoto
wget -q --show-progress --force-directories -O "${AC_DIR}3Dmigoto-1.3.16.zip" "$MIGOTO_URL"

# Check if the download was successful
if [ $? -ne 0 ]; then
    failure_message "Failed to download file."
fi

info_message "Unzipping 3Dmigoto"
# Unzip 3Dmigoto to the destination directory (quiet)
unzip -qq -o "${AC_DIR}3Dmigoto-1.3.16.zip" -d "$AC_DIR"

# Check if the unzip was successful
if [ $? -ne 0 ];then
    failure_message "Failed to unzip file."
fi

# Retrieve latest steamless release. Output is suppressed
STEAMLESS_URL=$(curl -s https://api.github.com/repos/atom0s/Steamless/releases/latest \
    | grep "browser_download_url.*Steamless.*zip" \
    | cut -d : -f 2,3 \
    | tr -d \" | tr -d ' ') >/dev/null 2>&1

# Check if a URL was found
if [ -z "$STEAMLESS_URL" ]; then
    failure_message "Failed to find the Steamless download URL."
fi

info_message "Downloading Steamless"
# Download the Steamless
wget -q "$STEAMLESS_URL" -O "${AC_DIR}Steamless.zip"

info_message "Unzipping Steamless"
# Unzip Steamless to the destination directory (quiet)
unzip -qq -o "${AC_DIR}Steamless.zip" -d "${AC_DIR}Steamless"

# Check if the unzip was successful
if [ $? -ne 0 ]; then
    failure_message "Failed to unzip Steamless."
fi

info_message "Prep finished (files moved/downloaded/unpacked). Launching Steamless next."
echo ""

# Map an extra Wine drive letter (G:) directly to the game folder for the file picker
if [ -d "$DOSDEV_DIR" ]; then
    ln -snf "$AC_DIR" "${DOSDEV_DIR}/g:" || failure_message "Failed to map Wine drive G: to $AC_DIR"
else
    failure_message "Proton prefix dosdevices directory not found at $DOSDEV_DIR; cannot map drive G:"
fi

instruction_message "In Steamless: click 'My Computer' → open drive G: → select Ace7Game.exe → click 'Open' → click 'Unpack file' → close after 'Successfully unpacked file'"
# Run Steamless executable with protontricks-launch and wait until closed
if flatpak list | grep -q com.github.Matoking.protontricks; then
    info_message "Running Steamless using Flatpak Protontricks..."
    flatpak run --command=protontricks-launch com.github.Matoking.protontricks --appid 502500 "${AC_DIR}Steamless/Steamless.exe" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        :
    else
        failure_message "Failed to execute Steamless with Flatpak Protontricks."
    fi
else
    info_message "Flatpak Protontricks not found, using system-installed Protontricks-launch..."
    protontricks-launch --appid 502500 "${AC_DIR}Steamless/Steamless.exe" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        :
    else
        failure_message "Failed to execute Steamless with system-installed Protontricks-launch."
    fi
fi

info_message "Renaming patched .exe"
# Rename the unpacked Ace7Game.exe file
if [ -f "${AC_DIR}Ace7Game.exe.unpacked.exe" ]; then
    mv "${AC_DIR}Ace7Game.exe.unpacked.exe" "${AC_DIR}Ace7Game.exe"
    if [ $? -eq 0 ]; then
        :
    else
        failure_message "Failed to rename Ace7Game.exe.unpacked.exe."
    fi
else
    failure_message "Ace7Game.exe.unpacked.exe not found in ${AC_DIR}."
fi

# Execute patching script
info_message "Applying resolution fix"
cd "$AC_DIR" || exit 1
if [ -f "${AC_DIR}resolution_patch.py" ]; then
    python3 "${AC_DIR}resolution_patch.py"
    if [ $? -eq 0 ]; then
        :
    else
        failure_message "Failed to execute resolution_patch.py."
    fi
else
    failure_message "resolution_patch.py not found in ${AC_DIR}."
fi

info_message "Resolution fix applied. If you want to clean up everything, run ./cleanup.sh"
