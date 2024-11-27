#!/bin/bash

# 3D Migoto URL
MIGOTO_URL="https://github.com/bo3b/3Dmigoto/releases/download/1.3.16/3Dmigoto-1.3.16.zip"
# Installation dir
AC_DIR="/home/deck/.local/share/Steam/steamapps/common/ACE COMBAT 7/"
# Scripts directory
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

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
            failure_message "Protontricks installation failed and could not verify an existing installation."
            failure_message "If you do not have Flatpak, install protontricks manually"
            failure_message "Exiting."
            exit 1
        fi
    fi
else
    success_message "Protontricks is already installed."
fi


info_message "Moving mod files to game directory"
# Move Mods, ShaderFixes, and magic.py to AC_DIR using rsync
for ITEM in "Mods" "ShaderFixes" "magic.py"; do
    if [ -e "$SCRIPT_DIR/$ITEM" ]; then
        rsync -a "$SCRIPT_DIR/$ITEM" "$AC_DIR"
        if [ $? -eq 0 ]; then
            success_message "$ITEM moved."
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
if [ $? -eq 0 ]; then
    success_message "Download completed successfully!"
else
    failure_message "Failed to download file."
fi

info_message "Unzipping 3Dmigoto"
# Unzip 3Dmigoto to the destination directory
unzip -o "${AC_DIR}3Dmigoto-1.3.16.zip" -d "$AC_DIR"

# Check if the unzip was successful
if [ $? -eq 0 ];then
    success_message "Unzip completed successfully!"
else
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
# Unzip Steamless to the destination directory
unzip -o "${AC_DIR}Steamless.zip" -d "${AC_DIR}Steamless"

# Check if the unzip was successful
if [ $? -eq 0 ]; then
    success_message "Steamless unzip completed successfully!"
else
    failure_message "Failed to unzip Steamless."
fi

info_message "Please wait, starting winecfg, this will take around 20-60 seconds."
instruction_message "Once winecfg window appears, open Drives → select 'Show dot files' and click 'OK'"

# Run winecfg with protontricks for the game and wait until closed
{
    if flatpak list | grep -q com.github.Matoking.protontricks; then
        info_message "Running winecfg using Flatpak Protontricks..."
        flatpak run com.github.Matoking.protontricks 502500 winecfg >/dev/null 2>&1
    else
        info_message "Flatpak Protontricks not found, using system-installed Protontricks..."
        protontricks 502500 winecfg >/dev/null 2>&1
    fi
}

flatpak run com.github.Matoking.protontricks 502500 winecfg >/dev/null 2>&1
    success_message "winecfg has been closed."
else
    failure_message "Failed to run winecfg."
fi

info_message "Steamless is starting now, this will take some time."
instruction_message "In Steamless: Select File to Unpack [...] and then navigate to:"
instruction_message "Disk '/' → home → deck → .local → share → Steam → steamapps → common → ACE COMBAT 7 → Ace7Game.exe"
instruction_message "Select 'Unpack file', and once you see 'Successfully unpacked file' close the Steamless window"
# Run Steamless executable with protontricks-launch and wait until closed
{
    if flatpak list | grep -q com.github.Matoking.protontricks; then
        info_message "Running Steamless using Flatpak Protontricks..."
        flatpak run --command=protontricks-launch com.github.Matoking.protontricks --appid 502500 "${AC_DIR}Steamless/Steamless.exe" >/dev/null 2>&1
    else
        info_message "Flatpak Protontricks not found, using system-installed Protontricks-launch..."
        protontricks-launch --appid 502500 "${AC_DIR}Steamless/Steamless.exe" >/dev/null 2>&1
    fi
}

flatpak run --command=protontricks-launch com.github.Matoking.protontricks --appid 502500 "${AC_DIR}Steamless/Steamless.exe" >/dev/null 2>&1
    success_message "Steamless has been closed."
else
    failure_message "Failed to execute Steamless."
fi

info_message "Renaming patched .exe"
# Rename the unpacked Ace7Game.exe file
if [ -f "${AC_DIR}Ace7Game.exe.unpacked.exe" ]; then
    mv "${AC_DIR}Ace7Game.exe.unpacked.exe" "${AC_DIR}Ace7Game.exe"
    if [ $? -eq 0 ]; then
        success_message "Renamed Ace7Game.exe.unpacked.exe to Ace7Game.exe successfully."
    else
        failure_message "Failed to rename Ace7Game.exe.unpacked.exe."
    fi
else
    failure_message "Ace7Game.exe.unpacked.exe not found in ${AC_DIR}."
fi

# Execute patching script
info_message "Applying resolution fix"
cd "$AC_DIR" || exit 1
if [ -f "${AC_DIR}magic.py" ]; then
    python3 "${AC_DIR}magic.py"
    if [ $? -eq 0 ]; then
        success_message "magic.py ran succesfully."
    else
        failure_message "Failed to execute magic.py."
    fi
else
    failure_message "magic.py not found in ${AC_DIR}."
fi
