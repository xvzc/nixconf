"""Library behind scripts/apt.py, the agent pressure-test runner."""

import pathlib

APT_DIR = pathlib.Path(__file__).resolve().parents[2]
DEFAULT_ROOT = pathlib.Path("/tmp/apt_f849b9cc2c36")


class AptError(Exception):
    """A failure to report to the user as one clear line, without a traceback."""
