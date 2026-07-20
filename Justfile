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
  uv venv --system-site-packages
  uv sync

compile:
  #!/usr/bin/env bash

  # Debian / Ubuntu build dependencies
  sudo apt install sox python3-dev libgirepository1.0-dev libgtk-3-dev gcc libcairo2-dev

  # Create isolated environment and compile
  uv venv
  uv sync