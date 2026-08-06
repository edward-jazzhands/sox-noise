# SoX Noise

[![badge](https://img.shields.io/github/v/release/edward-jazzhands/sox-noise)](https://github.com/edward-jazzhands/sox-noise/releases/latest)
[![badge](https://img.shields.io/badge/Requires_Python->=3.10-blue&logo=python)](https://python.org)
[![badge](https://img.shields.io/badge/license-Unlicense-blue)](https://opensource.org/license/unlicense)

## Note from Ed

This repo is a fork of the original SoX-Noise application by Jon Knapp. This fork is maintained by me (Edward Jazzhands) to make the software installable on current Linux distributions and Python versions.

The original application code is unchanged. Issues specific to the original application should be reported [upstream](https://github.com/Thann/sox-noise) when possible. 

I noticed SoX-Noise wasn't installable on modern Linux distributions without workarounds, as the original author only set up installing with the system pip (All modern Linux distros do not allow installing packages using the system pip). So I created a fork that modernizes the packaging (PEP 517/518, `pyproject.toml`, etc.) and set up a CI pipeline to test against numerous versions of python, and build and publish a .deb file (.rpm coming soon).

This program has been tested running on Python 3.10 through 3.14.

**Warning: Only Debian-based distros are officially supported at the moment. If you want to install this on other distros then you'll need to install from source and modify the `sudo apt install` lines to match your distro's package manager. The package names may also be different.**

## SoX Noise

Noise generator GUI powered by [Sound eXchange](http://sox.sourceforge.net/)

![screenshot](https://raw.githubusercontent.com/edward-jazzhands/sox-noise/refs/heads/main/screenshot.png)

## Installation

### Packaged Releases (Recommended)

Download the latest release from the [releases](https://github.com/edward-jazzhands/sox-noise/releases) page (Only Debian supported so far).

### Install from Source

This project is managed with UV. It is recommended to use it for development. For merely installing as a user, UV is recommended but not required.

This application requires GTK3 system dependencies. You can either use pre-made libraries, or you can compile everything yourself. Both options are provided in the Makefile along with keywords to use UV.

#### Option 1: Use System GTK Bindings (Recommended)

The install command will run `sudo apt` to check you have the required system dependencies and install them if you do not already have them (Including Sox).

From the project root (requires Makefile support):

```sh
make install
```

The above command will install using vanilla Python, which your Linux distro most likely has. If not you can run `sudo apt install python3`.

If you have UV installed, it is recommended to use the UV-based install instead:

```sh
make install WITH=uv
```

#### Option 2: Compile PyGObject in an Isolated Environment

If you prefer a fully isolated virtual environment without sharing system Python packages, install the required C headers and compiler tools to build PyGObject from source:

```sh
make compile
```

If you have UV installed, you can use the UV-based compile command instead:

```sh
make compile WITH=uv
```

## Running the App

After syncing your dependencies with either method, you can invoke the entrypoint script directly:

```sh
.venv/bin/sox-noise
```

If you synced with UV then it is preferable to use the UV run command:

```sh
uv run sox-noise
```

## Thanks and Copyright

Original SoX Noise project and this fork are licensed under Unlicense. See LICENSE file.

Thank you to Jon Knapp for writing the program.

[Original Project](https://github.com/Thann/sox-noise)