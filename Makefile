.ONESHELL:
SHELL := /bin/bash
.PHONY: build-deb install compile test nox

## Show this help message
help:
	@echo "Available targets:"
	@echo "  help            - Show this help message"
	@echo "  build-deb       - Build using dpkg-buildpackage for Debian"
	@echo "  install         - Install using available system packages"
	@echo "  install-with-uv - Same as install but using UV instead of vanilla Python"
	@echo "  compile         - Create isolated environment and compile"
	@echo "  compile-with-uv - Same as compile but using UV instead of vanilla Python"
	@echo "  test            - Set up the environment and run pytest"
	@echo "  nox             - Run the nox testing suite"

# build using dpkg-buildpackage for Debian
# The -us flag skips signing the source package
# -uc skips signing the .buildinfo and .changes files
# -b specifies building a binary-only package without rebuilding the source archive.
build-deb:
	dpkg-buildpackage -us -uc -b

# Install using available system packages
install:
	sudo apt install sox python3-gi gir1.2-gtk-3.0 libgtk-3-0

	# first check if .venv folder exists already:
	if [ -d ".venv" ]; then
		echo "Virtual environment already exists. Skipping creation."
		echo "To recreate the virtual environment, delete the .venv folder."
	else
		python3 -m venv .venv --system-site-packages
	fi

	source .venv/bin/activate
	pip install .

	mkdir -p ~/.local/share/applications
	cp thann.sox-noise.desktop ~/.local/share/applications/thann.sox-noise.desktop

# Install using available system packages
install-with-uv:
	sudo apt install sox python3-gi gir1.2-gtk-3.0 libgtk-3-0

	# first check if .venv folder exists already:
	if [ -d ".venv" ]; then
		echo "Virtual environment already exists. Skipping creation."
		echo "To recreate the virtual environment, delete the .venv folder."
	else
		uv venv --system-site-packages
	fi

	uv sync

	mkdir -p ~/.local/share/applications
	cp thann.sox-noise.desktop ~/.local/share/applications/thann.sox-noise.desktop

compile:
	sudo apt install sox python3-dev libgirepository-2.0-dev libgtk-3-dev gcc libcairo2-dev

	if [ -d ".venv" ]; then
		echo "Virtual environment already exists. Skipping creation."
		echo "To recreate the virtual environment, delete the .venv folder."
	else
		python3 -m venv .venv
	fi

	source .venv/bin/activate
	pip install .

	mkdir -p ~/.local/share/applications
	cp thann.sox-noise.desktop ~/.local/share/applications/thann.sox-noise.desktop

compile-with-uv:
	sudo apt install sox python3-dev libgirepository-2.0-dev libgtk-3-dev gcc libcairo2-dev

	if [ -d ".venv" ]; then
		echo "Virtual environment already exists. Skipping creation."
		echo "To recreate the virtual environment, delete the .venv folder."
	else
		uv venv
	fi

	uv sync
	mkdir -p ~/.local/share/applications
	cp thann.sox-noise.desktop ~/.local/share/applications/thann.sox-noise.desktop

# Sets up the environment and runs pytest
test:
	source ./tests/setup.bash
	uv run pytest tests -svvv
	source ./tests/teardown.bash

# Run the nox testing suite
nox:
	# the noxfile will run the setup and teardown scripts
	nox