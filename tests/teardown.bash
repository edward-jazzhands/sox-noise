#!/usr/bin/env bash

cleanup() {
    echo "Cleaning up..."
    # kill fluxbox before Xvfb on exit, so fluxbox shuts down cleanly
    pkill fluxbox 2>/dev/null
    pkill Xvfb 2>/dev/null
    rm -f /tmp/.X99-lock

    echo "Waiting 1 second for processes to shutdown..."
    sleep 1

    # check if Xvfb is still running
    if pgrep Xvfb > /dev/null; then
        echo "Xvfb is still running..."
    else
        echo "Xvfb shutdown was successful."
    fi

    if pgrep fluxbox > /dev/null; then
        echo "Fluxbox is still running..."
    else
        echo "Fluxbox shutdown was successful."
    fi
}

trap cleanup EXIT INT TERM