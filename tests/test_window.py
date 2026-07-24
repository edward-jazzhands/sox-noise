# Warning: If running in a headless environment, you won't be able to
# run this test directly without the required dependencies (X server, etc).
# Instead, run the test command (`just test` from the root of the project),
# or you can run the bash script to set up the dependencies and run them
# in the background (`bash tests/run_test.bash`).

from __future__ import annotations

import os
import signal
import subprocess
import sys
import time

from collections.abc import Iterator

import pytest
from pathlib import Path

venv_bin = Path(sys.executable).parent
sox_noise = venv_bin / "sox-noise"

APP_COMMAND: list[str] = [sox_noise.as_posix()]
WINDOW_TITLE: str = "SoX Noise"
STARTUP_TIMEOUT: float = 10.0
CLOSE_TIMEOUT: float = 3.0



def window_exists(title: str) -> bool:
    """Check whether an X11 window with the given title exists (requires wmctrl)."""

    result = subprocess.run(
        ["wmctrl", "-l"],
        capture_output=True,
        text=True,
    )
    return any(title in line for line in result.stdout.splitlines())


@pytest.fixture
def app_process() -> Iterator[subprocess.Popen[str]]:

    if "DISPLAY" not in os.environ:
        pytest.fail("No DISPLAY available. Run with xvfb-run or set DISPLAY.")

    process = subprocess.Popen(
        APP_COMMAND,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )

    yield process

    if process.poll() is None:
        process.send_signal(signal.SIGTERM)
        try:
            process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            process.kill()


def test_application_launches(app_process: subprocess.Popen[str]) -> None:

    if not subprocess.run(
        ["which", "wmctrl"],
        capture_output=True,
        text=True,
    ).returncode == 0:
        pytest.skip("wmctrl not available")


    deadline = time.time() + STARTUP_TIMEOUT

    while time.time() < deadline:
        if app_process.poll() is not None:
            stdout, stderr = app_process.communicate()
            pytest.fail(
                f"Application exited early\n\nstdout:\n{stdout}\n\nstderr:\n{stderr}"
            )

        if window_exists(WINDOW_TITLE):
            print(f"\nWindow with title '{WINDOW_TITLE}' was found.")
            # give it a second to settle
            time.sleep(0.50)
            # close the window
            subprocess.run(["wmctrl", "-c", WINDOW_TITLE])
            # wait for the window to close
            while time.time() < time.time() + CLOSE_TIMEOUT:
                if not window_exists(WINDOW_TITLE):
                    break
                else:
                    time.sleep(0.25)
            assert not window_exists(WINDOW_TITLE)
            print("Window closed successfully.")
            return

        time.sleep(0.25)

    pytest.fail(f"Application started but window '{WINDOW_TITLE}' never appeared")