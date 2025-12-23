#!/bin/bash
set -euo pipefail

# Paths
AC_DIR="/home/deck/.local/share/Steam/steamapps/common/ACE COMBAT 7/"
PFX_DIR="/home/deck/.local/share/Steam/steamapps/compatdata/502500/pfx"
DOSDEV_DIR="${PFX_DIR}/dosdevices"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_BASENAME="${REPO_DIR##*/}"

echo "This will remove temporary install artifacts (G: mapping, Steamless files, 3Dmigoto archives/extracts, leftover unpacked exe)."
echo "Starting in 20 seconds. Close this window or press Ctrl+C to abort."
sleep 20

# Remove G: mapping
if [ -L "${DOSDEV_DIR}/g:" ]; then
    rm -f "${DOSDEV_DIR}/g:"
    echo "Removed G: mapping"
fi

# Remove Steamless artifacts
[ -f "${AC_DIR}Steamless.zip" ] && rm -f "${AC_DIR}Steamless.zip" && echo "Removed Steamless.zip"
[ -d "${AC_DIR}Steamless" ] && rm -rf "${AC_DIR}Steamless" && echo "Removed Steamless folder"

# Remove 3Dmigoto artifacts
[ -f "${AC_DIR}3Dmigoto-1.3.16.zip" ] && rm -f "${AC_DIR}3Dmigoto-1.3.16.zip" && echo "Removed 3Dmigoto zip"
[ -d "${AC_DIR}3Dmigoto-1.3.16" ] && rm -rf "${AC_DIR}3Dmigoto-1.3.16" && echo "Removed extracted 3Dmigoto folder"

# Remove leftover unpacked exe if present
[ -f "${AC_DIR}Ace7Game.exe.unpacked.exe" ] && rm -f "${AC_DIR}Ace7Game.exe.unpacked.exe" && echo "Removed leftover Ace7Game.exe.unpacked.exe"

# Remove repository folder (from /tmp to avoid deleting CWD)
cd /tmp
if [ "$REPO_BASENAME" = "ac7-ultrawide-steamdeck" ] && [ -d "$REPO_DIR" ]; then
    rm -rf "$REPO_DIR"
    echo "Removed repository folder at $REPO_DIR"
else
    echo "Skipped removing repository folder (unexpected path: $REPO_DIR)"
fi

echo "Cleanup complete."
