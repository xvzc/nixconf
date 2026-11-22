"""Adapters turn a prepared run into a queue job and a log into normalized parts."""

import dataclasses
import re

from .. import AptError

TOOL_KINDS = {
    "bash": "shell",
    "shell": "shell",
    "read": "read",
    "edit": "edit",
    "multiedit": "edit",
    "notebookedit": "edit",
    "write": "write",
    "glob": "glob",
    "grep": "grep",
    "webfetch": "webfetch",
    "websearch": "websearch",
    "task": "subagent",
    "agent": "subagent",
    "subagent": "subagent",
}

# A tool refused by a permission rule or an approval prompt nobody can answer, as
# opposed to a tool that ran and failed.
DENIED = re.compile(
    r"cannot ask the user for permission|prevents you from using this|has been denied"
    r"|was denied|denied by (?:the )?(?:user|permission|rule|policy)|requires? (?:user )?approval",
    re.I,
)


def tool_kind(native_name):
    return TOOL_KINDS.get(native_name.lower(), "other")


def tool_call(native_name, tool_input, status="ok", error=None):
    kind = tool_kind(native_name)
    command = tool_input.get("command") if kind == "shell" and isinstance(tool_input, dict) else None
    return {
        "name": kind,
        "native_name": native_name,
        "input": tool_input,
        "command": command,
        "status": status,
        "error": error,
    }


def text_before_status(report):
    """True when the report message starts with text before <status>; None when it has no <status>."""
    if not report or "<status>" not in report:
        return None
    return not report.lstrip().startswith("<status>")


def failure_status(error_text):
    return "denied" if DENIED.search(error_text or "") else "error"


@dataclasses.dataclass
class Job:
    cmd: list
    env: dict = dataclasses.field(default_factory=dict)
    env_from: dict = dataclasses.field(default_factory=dict)
    stdin_file: str = ""


@dataclasses.dataclass
class Skip:
    reason: str


@dataclasses.dataclass
class RunSpec:
    agent: str
    prompt: str
    tokens: tuple
    model: str
    cwd: str
    cfg_dir: str
    config_dir: str  # empty OPENCODE_CONFIG_DIR shared by the batch
    dry_run: bool


class Adapter:
    """One agent CLI. Subclasses set `cli`, `supported_tokens`, and implement the rest."""

    cli = ""
    supported_tokens = frozenset()

    def __init__(self, profile, bundle, model):
        self.profile = profile
        self.bundle = bundle
        self.model = model

    def preflight(self):
        """Raises AptError when something a run needs is missing."""

    def cli_version(self):
        """The CLI version captured once per batch, or None if the log carries it."""
        return None

    def build_job(self, spec):
        """Returns a Job, or a Skip when the run needs a token this CLI cannot express."""
        unsupported = [t for t in spec.tokens if t not in self.supported_tokens]
        if unsupported:
            return Skip(f"{self.cli} cannot apply Run Options token(s): {', '.join(unsupported)}")
        return self.make_job(spec)

    def make_job(self, spec):
        raise NotImplementedError

    @staticmethod
    def normalize(log_path, agent):
        """Returns a dict with texts, tool_calls, report, report_found, cost_usd, errors,
        cli_version and events (the number of events parsed)."""
        raise NotImplementedError


def read_events(log_path):
    """Returns (events, unparseable_line_count); a missing log gives ([], 0)."""
    import json

    events, bad = [], 0
    try:
        with open(log_path) as f:
            for line in f:
                if not line.strip():
                    continue
                try:
                    ev = json.loads(line)
                except json.JSONDecodeError:
                    bad += 1
                    continue
                if isinstance(ev, dict):
                    events.append(ev)
                else:
                    bad += 1
    except FileNotFoundError:
        pass
    return events, bad


def adapter_class(cli):
    from .claude import ClaudeAdapter
    from .opencode import OpencodeAdapter

    cls = {"claude": ClaudeAdapter, "opencode": OpencodeAdapter}.get(cli)
    if cls is None:
        raise AptError(f"unknown cli {cli!r}")
    return cls
