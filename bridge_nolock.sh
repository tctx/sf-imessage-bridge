#!/usr/bin/env bash
set -e

echo "=== Synthetic Friends Bridge: No-Lock / No-Screensaver Setup ==="

echo "-> Disabling password requirement after sleep/screensaver..."
# Do NOT require password when the screen turns off or screensaver would start
defaults write com.apple.screensaver askForPassword -int 0
defaults write com.apple.screensaver askForPasswordDelay -int 0

echo "-> Disabling auto logout on idle..."
# 0 = disabled (no forced logout after X seconds of inactivity)
sudo defaults write /Library/Preferences/.GlobalPreferences com.apple.autologout.AutoLogOutDelay -int 0

echo "-> Disabling screensaver entirely..."
# 0 = never start screensaver
defaults -currentHost write com.apple.screensaver idleTime -int 0
defaults write com.apple.screensaver idleTime -int 0

echo "-> Adjusting power management so the system and display stay awake..."
# Never let the system go into full sleep on its own
sudo pmset -a sleep 0

# Never let the display sleep (required for haptic simulation)
sudo pmset -a displaysleep 0

# On some Macs, this extra flag helps prevent random deep sleep
sudo pmset -a disablesleep 1

# Optional but nice for a bridge box:
# - womp: wake on network access
# - powernap: allow background stuff without full wake
sudo pmset -a womp 1
sudo pmset -a powernap 1

echo "=== Done. You should RESTART the Mac mini once for everything to stick cleanly. ==="
echo "Security note: this machine will NOT require a password on wake/idle. Treat it like an appliance."
