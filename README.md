# Ace Combat 7 Resolution Fix for the Steam Deck

This mod adapts Ace Combat 7 (AC7) to work seamlessly with Steam Deck resolutions. This fork provides configuration automation, making installation and setup as easy as possible.

It enables you to patch the game without needing a mouse, keyboard, or Windows.

For more details, refer to the [original repository](https://github.com/massimilianodelliubaldini/ac7-ultrawide).

## How to Use

Clone the repository, navigate into the folder, make the script executable, and then run the patch script:

```bash
git clone https://github.com/Flumeded/ac7-ultrawide-steamdeck
cd ac7-ultrawide-steamdeck
chmod +x patch.sh
./patch.sh
```

Follow the instructions displayed in the console.

In Steam:
- Right-click on the game → Properties...
- Compatibility → Force the use of a specific Steam Play compatibility tool
- Select Proton 8.0-5
- Start the game 💫

## What It Does

- Ensures **protontricks** is installed.
- Downloads necessary files for the patch.
- Opens **winecfg** to manually enable hidden files in the file explorer.
- Launches **steamless** for manually patching the AC7 executable.
- Starts a Python script to apply the resolution fix.

## Uninstallation

1. Delete `d3d11.dll` from your game directory.
2. Delete `Ace7Game.exe` from your game directory.
3. Use "Verify integrity of game files" in Steam to re-download the most up-to-date executable.

