.ONESHELL:
SHELL := /bin/bash
.PHONY: help build-deb install compile test nox sync-tags release

WITH ?= default

## Show this help message
help:
	@echo "User commands:"
	@echo "  help            - Show this help message"
	@echo "  install         - Install using system libraries ('make install WITH=uv' to use UV)"
	@echo "  compile         - Create isolated environment and compile ('make compile WITH=uv' to use UV)"
	@echo ""
	@echo "Development commands:"
	@echo "  build-deb       - Build using dpkg-buildpackage for Debian"
	@echo "  test            - Set up the environment for headless testing and run pytest"
	@echo "  nox             - Run the nox testing suite"
	@echo "  sync-tags       - Syncs the tags from origin to local"
	@echo "  release         - Pushes the tags to origin"

# build using dpkg-buildpackage for Debian
# The -us flag skips signing the source package
# -uc skips signing the .buildinfo and .changes files
# -b specifies building a binary-only package without rebuilding the source archive.
build-deb:
	sudo apt build-dep .

	dpkg-buildpackage -us -uc -b

# Install using system libraries, ensures they are installed
install:
	sudo apt install sox python3-gi gir1.2-gtk-3.0 libgtk-3-0

	@echo "Installer set to $(WITH)..."
	@echo "HINT: Use 'make install WITH=uv' to use the UV package manager."

	# First check if .venv folder exists already:
	if [ -d ".venv" ]; then
		echo "Virtual environment already exists. Skipping creation."
		echo "To recreate the virtual environment, delete the .venv folder."
	else
		if [ "$(WITH)" = "uv" ]; then
			uv venv --system-site-packages
		else
			python3 -m venv .venv --system-site-packages
		fi
	fi
		
	if [ "$(WITH)" = "uv" ]; then
		uv sync
	else
		.venv/bin/pip install .
	fi

	mkdir -p ~/.local/share/applications
	cp thann.sox-noise.desktop ~/.local/share/applications/thann.sox-noise.desktop

compile:
	sudo apt install sox python3-dev libgirepository-2.0-dev libgtk-3-dev gcc libcairo2-dev

	@echo "Installer set to $(WITH)..."
	@echo "HINT: Use 'make compile WITH=uv' to use the UV package manager."

	if [ -d ".venv" ]; then
		echo "Virtual environment already exists. Skipping creation."
		echo "To recreate the virtual environment, delete the .venv folder."
	else
		if [ "$(WITH)" = "uv" ]; then
			uv venv
		else
			python3 -m venv .venv
		fi
	fi
	
	if [ "$(WITH)" = "uv" ]; then
		uv sync
	else
		.venv/bin/pip install .
	fi

	mkdir -p ~/.local/share/applications
	cp thann.sox-noise.desktop ~/.local/share/applications/thann.sox-noise.desktop

# Sets up the environment and runs pytest
test:
	source ./tests/setup.bash
	uv run pytest tests -svvv
	source ./tests/teardown.bash

# Run the nox testing suite
# the noxfile will run the setup and teardown scripts
nox:
	nox

# Syncs the tags from origin to local
sync-tags:
	git fetch --prune origin "+refs/tags/*:refs/tags/*"

# Run the .github/scripts files and push the tags
# see release.sh for more information
release: sync-tags
	bash .github/scripts/release.sh && git push --tags
	
# git push --tags does not push commits to your main branch (or any other branch). It only 
# uploads the "tag objects"—which are essentially just small pointers that say, "This 
# specific commit hash has the name v1.0."

# Because a tag is just metadata sitting "on top" of a commit that usually already exists 
# on the server, pushing a tag doesn't change the branch itself. And so the push request
# is not blocked by Github's branch protection rules even if its configured to block 
# pushes to the main branch.

