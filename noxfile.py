"""
Config file for Nox sessions
By Edward Jazzhands - 2025
"""

import nox
import pathlib
import shutil
import subprocess
import atexit

#---------------#
#  NOX CONFIG   #
#---------------#

nox.options.stop_on_first_error = True

# If you are doing dev work in some kind of niche environment such as a Docker
# container or on a server, you might not have symlinks available to you.
# In that case, you can set `nox.options.reuse_existing_virtualenvs = True

# Setting `nox.options.reuse_existing_virtualenvs` to True will make Nox
# reuse environments between runs, preventing however many GB of data from
# being written to your drive every time you run it. (Note: saves environments
# between runs of Nox, not between sessions of the same run).
nox.options.reuse_existing_virtualenvs = True

# If you do not need to reuse existing virtual environments, you can set
# `nox.options.reuse_existing_virtualenvs = False` and `DELETE_VENV_ON_EXIT = True`
# to delete the virtual environments after each session. This will ensure that
# you do not have any leftover virtual environments taking up space on your drive.
# Nox would just delete them when starting a new session anyway.
DELETE_VENV_ON_EXIT = False

if nox.options.reuse_existing_virtualenvs and DELETE_VENV_ON_EXIT:
    raise ValueError(
        "You cannot set both `nox.options.reuse_existing_virtualenvs`"
        "and `DELETE_VENV_ON_EXIT` to True (Technically this would not cause "
        "an error, but it would be pointless)."
    )

#---------------#
# PYTHON CONFIG #
#---------------#

PYTHON_VERSIONS = ["3.10", "3.11", "3.12", "3.13", "3.14"]

#-------------------#
# ENVIRONMENT SETUP #
#-------------------#

subprocess.run(["bash", "./tests/setup.bash"], check=True)
atexit.register(lambda: subprocess.run(["bash", "./tests/teardown.bash"]))


#---------------#
# NOX SESSIONS  #
#---------------#

@nox.session(
    venv_backend="uv",
    python=PYTHON_VERSIONS,
)
def tests(session: nox.Session) -> None:

    session.run_install(
        "uv",
        "sync",
        "--quiet",
        "--reinstall",
        f"--python={session.virtualenv.location}",
        env={"UV_PROJECT_ENVIRONMENT": session.virtualenv.location},
        external=True,
    )
    
    # The DISPLAY env var is needed to tell programs where to find the
    # X server virtual display created in setup_env.bash. Used by wmctrl in the test.
    session.run(
        "pytest", "tests", "-svvv", env={'DISPLAY': ":99"}
    
    )

    # This code here will make Nox delete each session after it finishes
    # if the `DELETE_VENV_ON_EXIT` flag is set to True.
    # If this is not set, Nox will leave the virtual environment on disk
    # after every session and only delete them all when it finishes everything.
    # This can take up a lot of space if you're testing numerous python versions
    # or packages, it can easily be like 10-20gb of space needed temporarily.
    # Even if its just for a few minutes, this can be a hassle if you're space-constrained.
    # By deleting environments between sessions, we ensure it only needs to take up
    # a few gigabytes of space at any given time.

    session_path = pathlib.Path(session.virtualenv.location)
    if session_path.exists() and session_path.is_dir() and DELETE_VENV_ON_EXIT:
        shutil.rmtree(session_path)
