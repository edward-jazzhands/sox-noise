# SoX Noise

## Note from Ed

This repo is a fork of the original SoX-Noise application by Jon Knapp. This fork is maintained by me (Edward Jazzhands) to make the software installable on current Linux distributions and Python versions.

The original application code is unchanged. Issues specific to the original application should be reported [upstream](https://github.com/Thann/sox-noise) when possible. 

I noticed SoX-Noise wasn't installable on modern Linux distributions without workarounds (All modern Linux distros do not allow installing packages using the system pip), so I created a fork that modernizes the packaging (PEP 517/518, `pyproject.toml`, etc.) and set up a CI pipeline to build and publish a .deb file (.rpm coming soon)

## SoX Noise

Noise generator GUI powered by [Sound eXchange](http://sox.sourceforge.net/)

![screenshot](https://github.com/edward-jazzhands/sox-noise/raw/master/screenshot.png)

## Installation

### Packaged Releases

Download the latest release from the [releases](https://github.com/edward-jazzhands/sox-noise/releases) page.

### Install from Source

This project is managed with UV. It is requierd to use it for development. For merely installing from source as a user, UV is recommended but not required.

This application requires GTK3 system dependencies. You can either use pre-made libraries, or you can compile everything yourself. Both options are provided (with or without UV, for 4 installing options in total) in the Makefile.

#### Option 1: Use System GTK Bindings (Recommended)

The install command will run `sudo apt` to check you have the required system dependencies and install them if you do not already have them (Including Sox).

From the project root (requires Makefile support):

```sh
make install
```

The above command will install using vanilla Python, which your Linux distro most likely has.

If you have UV installed, it is recommended to use the UV-based install instead:

```sh
make install-with-uv
```

#### Option 2: Compile PyGObject in an Isolated Environment

If you prefer a fully isolated virtual environment without sharing system Python packages, install the required C headers and compiler tools to build PyGObject from source:

```sh
make compile
```

If you have UV installed, you can use the UV-based compile command instead:

```sh
make compile-with-uv
```

## Running the App

After syncing your dependencies with either method, you can invoke the entrypoint script directly:

```sh
.venv/bin/sox-noise
```

If you synced with UV then it is preferable to use the UV run command instead of activating the python environment:

```sh
uv run sox-noise
```

You can run the application by activating the python environment and running `sox-noise`:

```sh
source .venv/bin/activate
sox-noise
```

## Thanks and Copyright

Original SoX Noise project and this fork are licensed under Unlicense. See LICENSE file.

Thank you to Jon Knapp for writing the program.

[Original Project](https://github.com/Thann/sox-noise)