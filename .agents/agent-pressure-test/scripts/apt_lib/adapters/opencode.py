"""opencode adapter.

Runs use the user's normal opencode setup: authentication and config. The bundle's
system.md is loaded through `instructions`, and OPENCODE_CONFIG_DIR points at an empty
directory so the deployed global AGENTS.md is not loaded a second time. The agent definition
and run-level rules are injected per run as OPENCODE_CONFIG_CONTENT, which opencode merges
with the user's config. Test sessions are stored in the user's opencode history, and
concurrent runs share the user's database.
"""

import json
import os
import subprocess

from .. import AptError
from . import Adapter, Job, failure_status, read_events, text_before_status, tool_call

SCHEMA_URL = "https://opencode.ai/config.json"


def run_version(env):
    """Runs `opencode --version` under `env`; returns its first output line."""
    try:
        proc = subprocess.run(["opencode", "--version", "--standalone"], env=env,
                              capture_output=True, text=True, check=True)
    except (OSError, subprocess.CalledProcessError) as e:
        raise AptError(f"opencode --version failed: {e}") from e
    return proc.stdout.strip().splitlines()[0] if proc.stdout.strip() else None


def run_env():
    return {"OPENCODE_DISABLE_CLAUDE_CODE": "1"}


class OpencodeAdapter(Adapter):
    cli = "opencode"
    supported_tokens = frozenset({"no-shell"})

    def __init__(self, profile, bundle, model):
        super().__init__(profile, bundle, model)
        self.agents_file = self.bundle / "opencode_agents.json"

    def preflight(self):
        for name in ("opencode_agents.json", "system.md"):
            if not (self.bundle / name).is_file():
                raise AptError(f"bundle {self.bundle} has no {name}")

    def cli_version(self):
        return run_version({**os.environ, **run_env()})

    def make_job(self, spec):
        with open(self.agents_file) as f:
            agents = json.load(f).get("agents", {})
        if spec.agent not in agents:
            raise AptError(f"{self.agents_file} has no agent {spec.agent}")
        entry = dict(agents[spec.agent])
        rules = list(entry.get("permissions", []))
        # Delegation is out of scope for every run; later rules win.
        rules.append({"action": "subagent", "resource": "*", "effect": "deny"})
        if "no-shell" in spec.tokens:
            rules.append({"action": "shell", "resource": "*", "effect": "deny"})
        # Keep the agent inside its scratch project.
        rules.append({"action": "external_directory", "resource": "*", "effect": "deny"})
        entry["permissions"] = rules
        config = {
            "$schema": SCHEMA_URL,
            "share": "disabled",
            "instructions": ["CLAUDE.md", str(self.bundle / "system.md")],
            "agents": {spec.agent: entry},
        }
        # The config is passed by value, so no file in the run's directory holds it.
        # opencode takes its working directory from PWD, not from the process cwd, so
        # PWD must name the scratch project; otherwise it works in the caller's directory.
        env = {**run_env(), "PWD": spec.cwd, "OPENCODE_CONFIG_DIR": spec.config_dir,
               "OPENCODE_CONFIG_CONTENT": json.dumps(config)}
        prompt_file = os.path.join(spec.cfg_dir, "prompt.txt")
        if not spec.dry_run:
            os.makedirs(spec.config_dir, exist_ok=True)
            os.makedirs(spec.cfg_dir)
            with open(prompt_file, "w") as f:
                f.write(spec.prompt)
        cmd = ["opencode", "run", "--standalone", "--format", "json",
               "--agent", spec.agent, "--model", spec.model]
        return Job(cmd, env=env, stdin_file=prompt_file)

    @staticmethod
    def normalize(log_path, agent):
        events, bad = read_events(log_path)
        out = {"cli_version": None, "texts": [], "tool_calls": [], "report": None,
               "report_found": False, "text_before_status": None, "cost_usd": None, "errors": [],
               "events": len(events)}
        texts, calls, cost = {}, {}, None  # keyed by part id; later events replace earlier ones
        for i, ev in enumerate(events):
            kind, part = ev.get("type"), ev.get("part") or {}
            key = part.get("id") or f"event-{i}"
            if kind == "text" and part.get("text", "").strip():
                texts[key] = (part.get("messageID"), part["text"].strip())
            elif kind == "tool_use":
                state = part.get("state") or {}
                status = state.get("status")
                if status == "completed":
                    calls[key] = tool_call(part.get("tool", ""), state.get("input", {}))
                else:
                    error = state.get("error") or f"tool call ended with status {status}"
                    calls[key] = tool_call(part.get("tool", ""), state.get("input", {}),
                                           failure_status(error) if status == "error" else "error", error)
            elif kind == "step_finish" and part.get("cost") is not None:
                cost = (cost or 0) + part["cost"]
            elif kind == "error":
                err = ev.get("error") or {}
                out["errors"].append(err.get("message") or (err.get("data") or {}).get("message") or json.dumps(err))
        if bad:
            out["errors"].append(f"{bad} unparseable log line(s)")
        out["cost_usd"] = cost
        out["tool_calls"] = list(calls.values())
        messages = list(texts.values())
        out["texts"] = [t for _, t in messages]
        # The report is the text of one whole message: its text parts joined in order.
        by_message = {}
        for message_id, text in messages:
            by_message.setdefault(message_id, []).append(text)
        joined = ["\n".join(parts) for parts in by_message.values()]
        reports = joined[-1:] if agent == "lead" else [t for t in joined if "<status>" in t]
        if reports:
            out["report"], out["report_found"] = reports[-1], True
        out["text_before_status"] = text_before_status(out["report"])
        return out
