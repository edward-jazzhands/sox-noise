#!/usr/bin/env bash

# check for all dependencies
# Xvfb is the virtual X server, fluxbox is the lightweight window manager,
# and wmctrl is used in unit tests to check for the window
commands=(Xvfb fluxbox wmctrl)
missing=0

for cmd in "${commands[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        missing=1
        break
    fi
done

if [[ "$missing" -eq 1 ]]; then
    echo "Missing at least one dependency. Running apt install..."
    sudo apt install xvfb fluxbox wmctrl
else
    echo "All testing dependencies found."
fi

if pgrep Xvfb > /dev/null; then
    echo "Xvfb is already running. Killing and restarting..."
    pkill Xvfb 2>/dev/null
    rm -f /tmp/.X99-lock
fi

if pgrep fluxbox > /dev/null; then
    echo "Fluxbox is already running. Killing and restarting..."
    pkill fluxbox 2>/dev/null
fi

sleep 1

# starts a virtual framebuffer X server on display number :99
# redirect Xvfb's stdout/stderr to /dev/null to suppress the xkbcomp warnings
Xvfb :99 -screen 0 1280x1024x24 > /dev/null 2>&1 &
export DISPLAY=:99
sleep 2
if pgrep Xvfb > /dev/null; then
    echo "X server started."
else
    echo "Xvfb failed to start. Exiting."
    exit 1
fi

# same here - silence the "Failed to read: session.X" defaults warnings
fluxbox -display :99 > /dev/null 2>&1 &
sleep 1
if pgrep fluxbox > /dev/null; then
    echo "Fluxbox started."
else
    echo "Fluxbox failed to start. Exiting."
    exit 1
fi