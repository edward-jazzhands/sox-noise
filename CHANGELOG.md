# Changelog for SoX Noise

## [0.1.0] 2026-07-22

Restructured fork with modern Python practices and a CI build pipeline.

First .deb build confirmed working.

**Changes from original repository:**

- Deleted `setup.py` and `MANIFEST.in` as it no longer works with modern Linux distributions.
- Created `pyproject.toml` file to replace `setup.py` and `MANIFEST.in`.
- Added pytest as a dev dependency.
- Created the `src/` directory to store the source code.
- Created the `debian/` directory to store debian build stuff.
- Created the `tests/` directory for all unit test stuff.
- Created the `.github/` directory for storing CI yaml and scripts
- Moved `sox_noise.py` to `src/sox_noise/sox_noise.py`. (no modifications, git blame maintained)
- Moved `main.ui` to `src/sox_noise/main.ui`. (no modifications, git blame maintained)
- Created an empty `__init__.py` file at `src/sox_noise/__init__.py`.
- Created `CHANGELOG.md` to track changes.
- Created `Justfile` to automate building the Debian package and storing project commands.
- Created a unit test at `tests/test_window.py`.
- Created `setup.bash` and `teardown.bash` for headless environment testing of GTK3
- Created `noxfile.py` for nox testing suite.
- Created `thann.sox-noise.desktop`, to be copied to the user's home directory if they clone the repo and install from source (using the `install` or `compile` commands in the Justfile).