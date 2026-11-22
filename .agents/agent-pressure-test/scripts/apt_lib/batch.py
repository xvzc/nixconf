"""Batch directory layout, the manifest and the exit-code file.

Agents can see <batch-dir>; the jobs file, manifest, per-run config and records live in
a private directory beside it that is not in any project's directory ancestry.
"""

import json
import os
import pathlib
import time

from . import DEFAULT_ROOT, AptError


class Layout:
    def __init__(self, root, name):
        self.root = pathlib.Path(root)
        self.name = name
        self.batch_dir = self.root / name
        self.work = self.batch_dir / "work"
        self.logs = self.batch_dir / "logs"
        self.private = self.root / "_private" / name
        self.opencode_config_dir = self.private / "opencode-config"
        self.jobs_file = self.private / "jobs.jsonl"
        self.manifest_file = self.private / "manifest.json"
        self.exits_file = self.private / "exits.json"
        self.records_dir = self.private / "records"

    @classmethod
    def new(cls, root):
        return cls(root, time.strftime("%Y%m%d-%H%M%S"))

    @classmethod
    def resolve(cls, batch, root=None):
        """`batch` is a batch name under the root, or a path to a batch directory."""
        if os.sep in batch:
            path = pathlib.Path(batch).resolve()
            layout = cls(path.parent, path.name)
        else:
            layout = cls(root or DEFAULT_ROOT, batch)
        if not layout.manifest_file.is_file():
            raise AptError(f"no manifest for batch {layout.name} at {layout.manifest_file}")
        return layout

    def create(self):
        self.batch_dir.mkdir(parents=True, exist_ok=False)
        for d in (self.work, self.logs, self.private, self.records_dir):
            d.mkdir(parents=True, exist_ok=True)

    def run_id(self, n):
        return f"{n:03d}"

    def scenario_dir(self, run):
        return self.work / f"repo_{run}"

    def project_dir(self, run):
        return self.scenario_dir(run) / "ledger-service"

    def cfg_dir(self, run):
        return self.private / "cfg" / run

    def log_path(self, run):
        return self.logs / f"run-{run}.jsonl"

    def err_path(self, run):
        return self.logs / f"run-{run}.err"

    def record_path(self, run):
        return self.records_dir / f"run-{run}.json"


def write_json(path, data):
    with open(path, "w") as f:
        json.dump(data, f, indent=1)
        f.write("\n")


def read_json(path):
    with open(path) as f:
        return json.load(f)


def write_jobs(path, jobs):
    with open(path, "w") as f:
        for job in jobs:
            f.write(json.dumps(job) + "\n")
