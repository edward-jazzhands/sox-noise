# build using dpkg-buildpackage for Debian
# The -us flag skips signing the source package
# -uc skips signing the .buildinfo and .changes files
# -b specifies building a binary-only package without rebuilding the source archive.
build-deb:
  dpkg-buildpackage -us -uc -b

# Install using available system packages
install:
  #!/usr/bin/env bash

  # Debian / Ubuntu
  sudo apt install sox python3-gi gir1.2-gtk-3.0 libgtk-3-0

  # Create virtual environment with system package access
  # first check if .venv folder exists already:
  if [ -d ".venv" ]; then
    echo "Virtual environment already exists. Skipping creation."
    echo "To recreate the virtual environment, delete the .venv folder."
  else
    uv venv --system-site-packages
  fi
  
  uv sync

  # copy the .desktop file to the user's home directory:
  cp thann.sox-noise.desktop ~/.local/share/applications/thann.sox-noise.desktop

compile:
  #!/usr/bin/env bash

  # Debian / Ubuntu build dependencies
  sudo apt install sox python3-dev libgirepository1.0-dev libgtk-3-dev gcc libcairo2-dev

  # Create isolated environment and compile
  # first check if .venv folder exists already:
  if [ -d ".venv" ]; then
    echo "Virtual environment already exists. Skipping creation."
    echo "To recreate the virtual environment, delete the .venv folder."
  else
    uv venv
  fi
  
  uv sync
  cp thann.sox-noise.desktop ~/.local/share/applications/thann.sox-noise.desktop

test:
  #!/usr/bin/env bash

  # Debian / Ubuntu testing dependencies
  # installs Xvfb (virtual X server), fluxbox (lightweight window manager),
  # and wmctrl (used in unit tests to check for the window)
  sudo apt install xvfb fluxbox wmctrl

  # starts a virtual framebuffer X server on display number :99
  # writes the DISPLAY variable into env vars
  # then starts fluxbox (needed by wmctrl)
  # the sleeps ensure that each stage worked and is ready
  Xvfb :99 -screen 0 1280x1024x24 &
  export DISPLAY=:99
  sleep 2
  fluxbox -display :99 &
  sleep 1

  nox