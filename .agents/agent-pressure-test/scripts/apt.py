#!/usr/bin/env python3
"""Prepares, runs and collects agent pressure-test batches on Claude Code or opencode.

  apt.py prepare --profile P --bundle <dir> [--model M] [--agents a,b] [--filter s,s]
                 [--trials N] [--dry-run]
  apt.py run <batch> [--max-concurrent N]
  apt.py collect <batch>
  apt.py summary <batch>

<batch> is a batch name under the root (default /tmp/apt_f849b9cc2c36, see --root) or
a path to a batch directory. Profiles are in profiles.json beside INSTRUCTION.md.
"""

import argparse
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from apt_lib import APT_DIR, AptError, batch, prepare, records  # noqa: E402

QUEUE_DONE = re.compile(r"^done\s+\d+/\d+ (\S+) exit=(-?\d+)")


def split(value):
    return tuple(v for v in value.split(",") if v)


def parse_queue_exits(lines, name_to_run):
    """Maps run number to exit code from run-queue's `done` lines."""
    exits = {}
    for line in lines:
        m = QUEUE_DONE.match(line)
        if m and m.group(1) in name_to_run:
            exits[name_to_run[m.group(1)]] = int(m.group(2))
    return exits


def cmd_prepare(args):
    opts = prepare.PrepareOptions(
        profile=args.profile, bundle=args.bundle, model=args.model or "", agents=split(args.agents),
        filters=split(args.filter), trials=args.trials, dry_run=args.dry_run,
        root=args.root or "",
    )
    manifest = prepare.prepare(opts)
    if not args.dry_run:
        print(manifest["batch_dir"])


def cmd_run(args):
    layout = batch.Layout.resolve(args.batch, args.root)
    manifest = batch.read_json(layout.manifest_file)
    name_to_run = {r["name"]: r["run"] for r in manifest["runs"]}
    queue = os.path.join(APT_DIR, "scripts", "run-queue.py")
    exits, lines = {}, []
    with open(layout.jobs_file) as jobs:
        proc = subprocess.Popen([sys.executable, queue, "--max-concurrent", str(args.max_concurrent)],
                                stdin=jobs, stdout=subprocess.PIPE, text=True)
        for line in proc.stdout:
            print(line, end="", flush=True)
            lines.append(line)
        proc.wait()
    batch.write_json(layout.exits_file, parse_queue_exits(lines, name_to_run))
    return proc.returncode


def cmd_collect(args):
    layout = batch.Layout.resolve(args.batch, args.root)
    recs = records.collect(layout)
    print(f"{len(recs)} records in {layout.records_dir}")


def cmd_summary(args):
    layout = batch.Layout.resolve(args.batch, args.root)
    paths = sorted(layout.records_dir.glob("run-*.json"))
    if not paths:
        raise AptError("no records; run collect first")
    for path in paths:
        record = batch.read_json(path)
        print(records.summary_line(record, records.changed_files(record["project"])))


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--root", help="batch root (default /tmp/apt_f849b9cc2c36)")
    sub = parser.add_subparsers(dest="command", required=True)
    p = sub.add_parser("prepare")
    p.add_argument("--profile", required=True)
    p.add_argument("--bundle", required=True, help="directory printed by `make agents`")
    p.add_argument("--model")
    p.add_argument("--agents", default="", help="comma-separated; default all")
    p.add_argument("--filter", default="", help="comma-separated scenario id substrings")
    p.add_argument("--trials", type=int, default=1)
    p.add_argument("--dry-run", action="store_true", help="print jobs; create nothing")
    p.set_defaults(func=cmd_prepare)
    for name, func in (("run", cmd_run), ("collect", cmd_collect), ("summary", cmd_summary)):
        p = sub.add_parser(name)
        p.add_argument("batch")
        if name == "run":
            p.add_argument("--max-concurrent", type=int, default=5)
        p.set_defaults(func=func)
    args = parser.parse_args(argv)
    try:
        return args.func(args) or 0
    except AptError as e:
        print(f"apt: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
