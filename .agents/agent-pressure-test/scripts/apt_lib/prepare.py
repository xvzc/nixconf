"""Builds a batch: projects, prompts, per-run config, jobs and manifest."""

import dataclasses
import json
import os
import pathlib
import shutil
import subprocess

from . import APT_DIR, AptError, batch, scenarios
from .adapters import RunSpec, Skip, adapter_class

COMMIT_IDENTITY = ["-c", "user.name=dev", "-c", "user.email=dev@example.com"]


@dataclasses.dataclass
class PrepareOptions:
    profile: str
    bundle: str
    model: str = ""
    agents: tuple = ()
    filters: tuple = ()
    trials: int = 1
    dry_run: bool = False
    root: str = ""
    apt_dir: str = str(APT_DIR)


def load_profile(apt_dir, name):
    path = os.path.join(apt_dir, "profiles.json")
    profiles = batch.read_json(path)
    if name not in profiles:
        raise AptError(f"unknown profile {name}; known: {', '.join(profiles)}")
    return profiles[name]


def build_project(apt_dir, scenario, project):
    """Creates the scenario's project with setup.sh, then copies and commits fixtures."""
    proc = subprocess.run(
        [os.path.join(apt_dir, "scripts", "setup.sh"), "--dest", project, *scenario.setup_flags],
        capture_output=True, text=True,
    )
    if proc.returncode != 0:
        raise AptError(f"setup.sh failed for {scenario.id}: {proc.stderr.strip()}")
    if not scenario.fixture_id:
        return
    fixtures = os.path.join(apt_dir, "fixtures", scenario.fixture_id)
    if not os.path.isdir(fixtures):
        raise AptError(f"{scenario.id}: fixtures/{scenario.fixture_id}/ does not exist")
    shutil.copytree(fixtures, project, dirs_exist_ok=True)
    if scenario.commit_message:
        for args in (["add", "-A"], [*COMMIT_IDENTITY, "commit", "-q", "-m", scenario.commit_message]):
            proc = subprocess.run(["git", "-C", project, *args], capture_output=True, text=True)
            if proc.returncode != 0:
                raise AptError(f"{scenario.id}: committing fixtures failed: {proc.stderr.strip()}")


def _check_agents(bundle, cli, agents):
    key = "claude_agents.json" if cli == "claude" else "opencode_agents.json"
    path = os.path.join(bundle, key)
    if not os.path.isfile(path):
        raise AptError(f"bundle {bundle} has no {key}")
    defined = batch.read_json(path)
    defined = defined.get("agents", defined) if cli == "opencode" else defined
    missing = sorted(set(agents) - set(defined))
    if missing:
        raise AptError(f"{key} does not define agent(s): {', '.join(missing)}")


def prepare(opts, say=print):
    """Prepares a batch and returns its manifest; with dry_run, creates nothing."""
    apt_dir = opts.apt_dir
    profile = load_profile(apt_dir, opts.profile)
    model = opts.model or profile.get("default_model", "")
    if not model:
        raise AptError(f"profile {opts.profile} has no default model; pass --model")
    if opts.trials < 1:
        raise AptError("--trials must be at least 1")
    bundle = os.path.abspath(opts.bundle)
    adapter = adapter_class(profile.get("cli"))(profile, pathlib.Path(bundle), model)

    pairs = scenarios.select(apt_dir, list(opts.agents) or None, list(opts.filters) or None)
    if not pairs:
        raise AptError("no scenarios selected")
    _check_agents(bundle, adapter.cli, {a for _, a in pairs})
    if not opts.dry_run:
        adapter.preflight()

    layout = batch.Layout.new(opts.root or batch.DEFAULT_ROOT)
    manifest = {
        "schema": 1, "batch": layout.name, "batch_dir": str(layout.batch_dir),
        "private_dir": str(layout.private), "profile": opts.profile,
        "cli": adapter.cli, "model": model, "bundle": bundle, "cli_version": None, "runs": [],
    }
    if not opts.dry_run:
        layout.create()
        manifest["cli_version"] = adapter.cli_version()

    jobs = []
    n = 0
    for scenario, agent in pairs:
        for trial in range(1, opts.trials + 1):
            run = layout.run_id(n)
            n += 1
            project = str(layout.project_dir(run)) if scenario.has_project else ""
            cwd = project or str(layout.scenario_dir(run))
            if not opts.dry_run:
                os.makedirs(layout.scenario_dir(run))
                if scenario.has_project:
                    build_project(apt_dir, scenario, project)
            spec = RunSpec(agent, scenarios.compose_prompt(scenario, agent), scenario.run_options, model,
                           cwd, str(layout.cfg_dir(run)), str(layout.opencode_config_dir), opts.dry_run)
            result = adapter.build_job(spec)
            entry = {
                "run": run, "name": scenarios.run_name(scenario, agent, trial), "scenario": scenario.id,
                "agent": agent, "trial": trial, "profile": opts.profile, "cli": adapter.cli,
                "model": model, "project": cwd, "cfg": str(layout.cfg_dir(run)),
                "log": str(layout.log_path(run)), "status": "prepared", "skip_reason": None,
            }
            if isinstance(result, Skip):
                entry.update(status="skipped", skip_reason=result.reason)
            else:
                job = {"name": entry["name"], "cwd": cwd, "cmd": result.cmd,
                       "stdout": entry["log"], "stderr": str(layout.err_path(run))}
                for field in ("env", "env_from", "stdin_file"):
                    if getattr(result, field):
                        job[field] = getattr(result, field)
                jobs.append(job)
            manifest["runs"].append(entry)

    if opts.dry_run:
        for job in jobs:
            say(json.dumps(job))
        for entry in manifest["runs"]:
            if entry["status"] == "skipped":
                say(f"skipped {entry['name']}: {entry['skip_reason']}")
        return manifest
    batch.write_jobs(layout.jobs_file, jobs)
    batch.write_json(layout.manifest_file, manifest)
    say(f"batch {layout.name}: {len(jobs)} prepared, {len(manifest['runs']) - len(jobs)} skipped")
    return manifest
