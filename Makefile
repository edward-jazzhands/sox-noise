.ONESHELL:
SHELL := /bin/bash
.SILENT:
.PHONY: help install compile desktop-file test nox build-deb sync-tags release container lintian appstream
SUDO := $(shell [[ "$$USER" == "root" ]] && echo "" || echo "sudo")

WITH ?= default
ENV ?= default

help:
	@echo "User commands:"
	@echo "  help            - Show this help message"
	@echo "  install         - Install using system libraries ('make install WITH=uv' to use UV)"
	@echo "  compile         - Create isolated environment and compile ('make compile WITH=uv' to use UV)"
	@echo ""
	@echo "Development commands:"
	@echo "  build-deb       - Build using dpkg-buildpackage for Debian"
	@echo "  test            - Set up the environment for headless testing and run pytest ('make test WITH=uv' to use UV)"
	@echo "  nox             - Run the nox testing suite (UV is REQUIRED to run this)"
	@echo "  sync-tags       - Syncs the tags from origin to local"
	@echo "  lintian         - Runs lintian on the built .changes file"
	@echo "  container       - "
	@echo "  appstream    "
	@echo "  release         - Pushes the tags to origin"

# this is an actual file, so no PHONY
.apt-updated:
	$(SUDO) apt update
	touch .apt-updated

PACKAGES := sox python3-gi gir1.2-gtk-3.0 libgtk-3-0

install: .apt-updated
	$(SUDO) apt install $(PACKAGES)

	@echo ""
	@echo "Installer set to $(WITH)..."
	if [ "$(WITH)" = "default" ]; then
		@echo "HINT: Use 'make install WITH=uv' to use the UV package manager."
	fi
	@echo ""

	# First check if .venv folder exists already:
	if [ -d ".venv" ]; then
		echo "Virtual environment already exists. Skipping creation."
		echo "To recreate the virtual environment, delete the .venv folder."
	else
		if [ "$(WITH)" = "uv" ]; then
			uv venv --system-site-packages
		else
			$(SUDO) apt install python3-venv
			python3 -m venv .venv --system-site-packages
		fi
	fi
		
	if [ "$(WITH)" = "uv" ]; then
		if [ "$(ENV)" = "dev" ]; then
			uv sync
		else
			uv sync --no-dev
		fi
	else
		if [ "$(ENV)" = "dev" ]; then
			.venv/bin/pip install -e ".[pytest]"
		else
			.venv/bin/pip install .
		fi
	fi

	$(MAKE) desktop-file

COMPILING_PKGS := sox python3-dev libgirepository-2.0-dev libgtk-3-dev gcc libcairo2-dev

compile: .apt-updated
	$(SUDO) apt install $(COMPILING_PKGS)

	@echo ""
	@echo "Installer set to $(WITH)..."
	if [ "$(WITH)" = "default" ]; then
		@echo "HINT: Use 'make compile WITH=uv' to use the UV package manager."
	fi
	@echo ""

	if [ -d ".venv" ]; then
		echo "Virtual environment already exists. Skipping creation."
		echo "To recreate the virtual environment, delete the .venv folder."
	else
		if [ "$(WITH)" = "uv" ]; then
			uv venv
		else
			$(SUDO) apt install python3-venv
			python3 -m venv .venv
		fi
	fi
	
	if [ "$(WITH)" = "uv" ]; then
		if [ "$(ENV)" = "dev" ]; then
			uv sync --extra compile
		else
			uv sync --no-dev --extra compile
		fi
	else
		if [ "$(ENV)" = "dev" ]; then
			.venv/bin/pip install -e ".[compile,pytest]"
		else
			.venv/bin/pip install ".[compile]"
		fi
	fi

	$(MAKE) desktop-file

desktop-file:
	mkdir -p ~/.local/share/applications
	cp io.github.edward_jazzhands.SoxNoise.desktop ~/.local/share/applications/io.github.edward_jazzhands.SoxNoise.desktop

# Sets up the environment and runs pytest
# the status arg 
test:
	source ./tests/setup.bash
	if [ "$(WITH)" = "uv" ]; then
		uv run pytest tests -svvv; status=$$?
	else
		.venv/bin/pytest tests -svvv; status=$$?
	fi
	source ./tests/teardown.bash
	exit $$status


# Run the nox testing suite
# the noxfile will run the setup and teardown scripts
nox:
	nox

# build using dpkg-buildpackage for Debian
# The -us flag skips signing the source package
# -uc skips signing the .buildinfo and .changes files
# -b specifies building a binary-only package without rebuilding the source archive.
build-deb: .apt-updated
	$(SUDO) apt build-dep .
	dpkg-buildpackage -us -uc -b

clean:
	rm -rf src/sox_noise.egg-info
	rm -rf build
	rm -rf __pycache__
	rm -rf .pytest_cache
	rm -rf .nox


# Syncs the tags from origin to local
sync-tags:
	git fetch --prune origin "+refs/tags/*:refs/tags/*"

# Run the release script and push the tags on success.
# Only release with this command, it contains a bunch of safety checks.
# see release.sh for more information
release: sync-tags
	bash .github/scripts/release.sh && git push --tags

container:
	if ! command -v systemd-nspawn &>/dev/null; then
		$(SUDO) apt install systemd-container
	fi
	if ! command -v debootstrap &>/dev/null; then
		$(SUDO) apt install debootstrap
	fi

	# only create new container if it doesn't exist already:
	if ! test -d /var/lib/machines/testcontainer/var/lib/dpkg; then
		$(SUDO) debootstrap stable /var/lib/machines/testcontainer http://deb.debian.org/debian
		# immediately create an admin password for logging in:
		$(SUDO) systemd-nspawn -D /var/lib/machines/testcontainer /bin/bash -c "passwd"
	fi
	$(SUDO) systemd-nspawn -bD /var/lib/machines/testcontainer --bind=$(CURDIR):/app

lintian:
	if ! command -v lintian &>/dev/null; then
		$(SUDO) apt install lintian
	fi
	pkg_name=$$(dpkg-parsechangelog -SSource)
	pkg_version=$$(dpkg-parsechangelog -SVersion | sed 's/^[0-9]*://')
	arch=$$(dpkg --print-architecture)
	lintian -i -I --pedantic --profile debian "../$${pkg_name}_$${pkg_version}_$${arch}.changes"

appstream:
	if ! command -v appstream &>/dev/null; then
		$(SUDO) apt install appstream
	fi
	appstream-util validate-relax debian/io.github.edward_jazzhands.SoxNoise.metainfo.xml