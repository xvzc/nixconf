"""Parses scenario files and selects the (scenario, agent) pairs to run."""

import dataclasses
import os
import re

from . import AptError

# Run Options tokens that INSTRUCTION.md defines. An adapter that cannot express one
# skips the run instead of failing prepare.
KNOWN_TOKENS = frozenset({"no-shell"})

# Appended to every prompt except lead's (INSTRUCTION.md, procedure step 2).
REPORT_REQUEST = (
    "Report in XML-tagged sections. Start with <status>, one of successful,\n"
    "partially_successful, needs_decision, or blocked. Then give <summary>,\n"
    "<assumptions>, and <questions>; if you changed files, also give <files-changed>,\n"
    "each file with what changed and why, and <checks>, each check run with its\n"
    "command and result."
)

COMMIT_PHRASE = re.compile(r"commit\s+it\s+with\s+the\s+message\s+`([^`]+)`")


@dataclasses.dataclass(frozen=True)
class Scenario:
    id: str
    owner: str  # an agent name, or "common"
    path: str
    has_project: bool
    setup_flags: tuple  # setup.sh arguments other than --dest
    fixture_id: str  # fixtures/<id>/ to copy, or "" for none
    commit_message: str  # commit message for the copied fixtures, or ""
    context: str
    prompt: str
    run_options: tuple  # Run Options tokens


def section(text, name):
    m = re.search(rf"^## {re.escape(name)}\n(.*?)(?=^## |\Z)", text, re.S | re.M)
    return m.group(1).strip() if m else ""


def fenced_block(text):
    m = re.search(r"```[a-z]*\n(.*?)```", text, re.S)
    return m.group(1).strip() if m else ""


def parse_scenario(path):
    with open(path) as f:
        text = f.read()
    sid = re.sub(r"\.md$", "", path.rsplit("/", 1)[-1])
    setup = section(text, "Setup")
    prompt = fenced_block(section(text, "Prompt"))
    if not prompt:
        raise AptError(f"{sid}: no fenced Prompt block")

    has_project = not setup.startswith("No files")
    flags = ()
    if has_project:
        command = fenced_block(setup).split()
        if not command or command[0] != "setup.sh":
            raise AptError(f"{sid}: Setup has no setup.sh command")
        flags = tuple(a for a in command[1:] if a not in ("--dest", "<dir>"))
    fixture = re.search(r"`fixtures/([^`/]+)/`", setup)
    commit = COMMIT_PHRASE.search(" ".join(setup.split()))

    tokens = tuple(re.findall(r"^- `([a-z-]+)`", section(text, "Run Options"), re.M))
    unknown = [t for t in tokens if t not in KNOWN_TOKENS]
    if unknown:
        raise AptError(f"{sid}: unknown Run Options token(s): {', '.join(unknown)}")

    return Scenario(
        id=sid,
        owner=sid.split("_", 1)[0],
        path=path,
        has_project=has_project,
        setup_flags=flags,
        fixture_id=fixture.group(1) if fixture else "",
        commit_message=commit.group(1) if commit else "",
        context=section(text, "Context"),
        prompt=prompt,
        run_options=tokens,
    )


def compose_prompt(scenario, agent):
    parts = [scenario.context] if scenario.context else []
    parts.append(scenario.prompt)
    if agent != "lead":
        parts.append(REPORT_REQUEST)
    return "\n\n".join(parts)


def run_name(scenario, agent, trial):
    """Job name: common scenarios carry the agent as a prefix."""
    prefix = f"{agent}_" if scenario.owner == "common" else ""
    return f"{prefix}{scenario.id}-{trial}"


def _scenario_files(directory):
    if not os.path.isdir(directory):
        return []
    return sorted(
        os.path.join(directory, f) for f in os.listdir(directory) if f.endswith(".md")
    )


def available_agents(apt_dir):
    base = os.path.join(apt_dir, "scenarios", "per-agent")
    return sorted(d for d in os.listdir(base) if os.path.isdir(os.path.join(base, d)))


def select(apt_dir, agents=None, filters=None):
    """Returns (scenario, agent) pairs: each selected agent's own scenarios, then the
    common ones. scenarios/deferred/ is never read."""
    known = available_agents(apt_dir)
    agents = agents or known
    bad = [a for a in agents if a not in known]
    if bad:
        raise AptError(f"unknown agent(s): {', '.join(bad)}; known: {', '.join(known)}")
    common = [parse_scenario(p) for p in _scenario_files(os.path.join(apt_dir, "scenarios", "common"))]
    pairs = []
    for agent in sorted(agents):
        own = _scenario_files(os.path.join(apt_dir, "scenarios", "per-agent", agent))
        pairs += [(parse_scenario(p), agent) for p in own]
        pairs += [(s, agent) for s in common]
    if filters:
        pairs = [(s, a) for s, a in pairs if any(f in s.id for f in filters)]
    return pairs
