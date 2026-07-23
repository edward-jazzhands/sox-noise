# Changelog for SoX Noise

## [0.1.0] 2026-07-22

First local .deb build confirmed working.

**Changes from original repository:**

- Deleted `setup.py` and `MANIFEST.in` as it no longer works with modern Linux distributions.
- Created `pyproject.toml` file to replace `setup.py` and `MANIFEST.in`.
- Created the `src/` directory to store the source code.
- Moved `sox_noise.py` to `src/sox_noise/sox_noise.py`. (no modifications, git blame maintained)
- Moved `main.ui` to `src/sox_noise/main.ui`. (no modifications, git blame maintained)
- Created an empty `__init__.py` file at `src/sox_noise/__init__.py`.
- Created `CHANGELOG.md` to track changes.
- Created `Justfile` to automate building the Debian package and storing project commands.
- Created a unit test at `tests/test_window.py`.
- Created `noxfile.py` for nox testing suite.
- Created the `debian/` directory to store debian build stuff.
- Created `thann.sox-noise.desktop`, to be copied to the user's home directory if they clone the repo and install from source (using the `install` or `compile` commands in the Justfile).