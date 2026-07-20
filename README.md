# SoX Noise

## Note from Ed

This repo is a fork of the original SoX-Noise application by Jon Knapp. This fork is maintained by Edward Jazzhands for packaging modernization and distribution purposes. This distribution exists to make the software installable on current Linux distributions and Python versions.

The original application code is unchanged except for packaging and compatibility improvements needed to support modern Python environments. Issues specific to the original application should be reported [upstream](https://github.com/Thann/sox-noise) when possible. 

I noticed SoX-Noise wasn't installable on modern Linux distributions without workarounds (Distros such as Debian/Ubuntu do not allow using the system pip), so I created a fork that modernizes the packaging (PEP 517/518, `pyproject.toml`, etc.) and set up a CI pipeline to build and publish .deb and .rpm packages.

## SoX Noise

Noise generator GUI powered by [Sound eXchange](http://sox.sourceforge.net/)

![screenshot](https://github.com/edward-jazzhands/sox-noise/raw/master/screenshot.png)

## Installation

### Packaged Releases

#! TODO



### Install from Source

This application requires GTK3 system dependencies. You can set up your local development environment using `uv` in one of two ways:

#### Option 1: Use System GTK Bindings (Recommended)

Install the pre-compiled GTK bindings via your package manager, then allow `uv` to access system site-packages:

```bash

```

#### Option 2: Compile PyGObject in an Isolated Environment

If you prefer a fully isolated virtual environment without sharing system Python packages, install the required C headers and compiler tools to let `uv` build PyGObject from source:

```bash


```

### Running the App

After syncing your dependencies with either method, run the application using `uv`:

```bash
uv run sox-noise

```