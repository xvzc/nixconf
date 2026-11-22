"""Normalized run records and the summary line built from them."""

import os
import re
import subprocess

from . import batch
from .adapters import adapter_class

SCHEMA = 1
STATUS_TAG = re.compile(r"<status>\s*(\w+)\s*</status>")


def build_record(run, parsed, exit_code):
    """`run` is a manifest run entry; `parsed` is an adapter's normalize() result or None."""
    parsed = parsed or {}
    skipped = run["status"] == "skipped"
    errors = list(parsed.get("errors", []))
    if skipped:
        status = "skipped"
    else:
        if not parsed.get("events"):
            errors.append("log has no events")
        status = "failed" if errors or exit_code not in (0, None) else "completed"
    return {
        "schema": SCHEMA,
        "run": run["run"],
        "name": run["name"],
        "scenario": run["scenario"],
        "agent": run["agent"],
        "trial": run["trial"],
        "cli": run["cli"],
        "cli_version": parsed.get("cli_version") or run.get("cli_version"),
        "profile": run["profile"],
        "model": run["model"],
        "status": status,
        "skip_reason": run.get("skip_reason"),
        "exit_code": exit_code,
        "report": parsed.get("report"),
        "report_found": bool(parsed.get("report_found")),
        "text_before_status": parsed.get("text_before_status"),
        "texts": parsed.get("texts", []),
        "tool_calls": parsed.get("tool_calls", []),
        "cost_usd": parsed.get("cost_usd"),
        "errors": errors,
        "log": run.get("log"),
        "project": run.get("project"),
    }


def collect(layout):
    """Writes one record per manifest run; returns the records."""
    manifest = batch.read_json(layout.manifest_file)
    exits = batch.read_json(layout.exits_file) if layout.exits_file.is_file() else {}
    normalize = adapter_class(manifest["cli"]).normalize
    records = []
    for run in manifest["runs"]:
        parsed = None
        if run["status"] != "skipped":
            parsed = normalize(run["log"], run["agent"])
        run = {**run, "cli_version": manifest.get("cli_version")}
        record = build_record(run, parsed, exits.get(run["run"]))
        batch.write_json(layout.record_path(run["run"]), record)
        records.append(record)
    return records


def changed_files(project):
    """`git status --short` lines for the project, minus devenv.lock; None if not a repo."""
    if not project or not os.path.isdir(os.path.join(project, ".git")):
        return None
    proc = subprocess.run(["git", "-C", project, "status", "--short"], capture_output=True, text=True)
    if proc.returncode != 0:
        return None
    return [l.strip() for l in proc.stdout.splitlines() if l[3:].strip() != "devenv.lock"]


def summary_line(record, files):
    model = f"{record['cli']}/{record['model']}"
    if record["status"] == "skipped":
        return f"{record['name']}  {model}  skipped: {record['skip_reason']}"
    tag = STATUS_TAG.search(record["report"] or "")
    reported = tag.group(1) if tag else "none"
    preceded = {True: "yes", False: "no", None: "-"}[record.get("text_before_status")]
    changed = "-" if files is None else (", ".join(files) or "none")
    cost = "-" if record["cost_usd"] is None else f"${record['cost_usd']:.4f}"
    return (f"{record['name']}  {model}  run={record['status']}  report={reported}  "
            f"text-before-status={preceded}  changed={changed}  cost={cost}")
