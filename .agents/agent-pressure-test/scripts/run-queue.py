#!/usr/bin/env python3
"""Run scenario commands read as JSON Lines from stdin, several at a time.

Usage: run-queue.py [--max-concurrent N] < jobs

Each line of stdin is one job:
  {"name": ..., "cwd": ..., "cmd": [...], "stdout": ..., "stderr": ...}
`cmd` is an argument list run without a shell. stdin is /dev/null. At most
--max-concurrent jobs (default 5) run at once.

A job may also carry these optional fields:
  "env":        {NAME: value}, merged over this process's environment.
  "env_from":   {TARGET: SOURCE}, sets TARGET to the value of this process's SOURCE
                variable when the job starts, so a job file names a secret without
                holding it. A missing SOURCE fails that job.
  "stdin_file": a path opened as the job's stdin instead of /dev/null.

Prints a `start` line when a job starts and a `done` line when it ends, then a
summary. Exits 0 when every job ran, whatever their exit codes, and 1 when a job
could not start or the input is invalid.
"""

import argparse
import contextlib
import json
import os
import subprocess
import sys
import threading
import time
from concurrent.futures import ThreadPoolExecutor

FIELDS = ("name", "cwd", "cmd", "stdout", "stderr")

lock = threading.Lock()
finished = 0


def say(line):
    with lock:
        print(line, flush=True)


def load_jobs(lines):
    jobs = []
    for n, line in enumerate(lines, 1):
        if not line.strip():
            continue
        try:
            job = json.loads(line)
        except json.JSONDecodeError as e:
            sys.exit(f"run-queue: line {n}: invalid JSON: {e}")
        missing = [k for k in FIELDS if k not in job]
        if missing:
            sys.exit(f"run-queue: line {n}: missing fields: {', '.join(missing)}")
        if not isinstance(job["cmd"], list) or not job["cmd"]:
            sys.exit(f"run-queue: line {n}: cmd must be a non-empty list")
        if not isinstance(job.get("env", {}), dict) or not isinstance(job.get("env_from", {}), dict):
            sys.exit(f"run-queue: line {n}: env and env_from must be objects")
        if not isinstance(job.get("stdin_file", ""), str):
            sys.exit(f"run-queue: line {n}: stdin_file must be a path")
        jobs.append(job)
    if not jobs:
        sys.exit("run-queue: no jobs on stdin")
    return jobs


def job_environment(job):
    """Returns the environment for a job; raises KeyError naming a missing env_from source."""
    env = {**os.environ, **job.get("env", {})}
    for target, source in job.get("env_from", {}).items():
        if source not in os.environ:
            raise KeyError(f"env_from source {source} is not set")
        env[target] = os.environ[source]
    return env


def run(job, index, total):
    """Runs one job; returns its exit code, or None if it could not start."""
    global finished
    say(f"start {index}/{total} {job['name']}")
    began = time.monotonic()
    try:
        env = job_environment(job)
        stdin = open(job["stdin_file"]) if "stdin_file" in job else contextlib.nullcontext(subprocess.DEVNULL)
        with open(job["stdout"], "w") as out, open(job["stderr"], "w") as err, stdin as inp:
            code = subprocess.run(
                job["cmd"], cwd=job["cwd"], env=env, stdin=inp, stdout=out, stderr=err
            ).returncode
    except (OSError, KeyError) as e:
        reason = e.args[0] if isinstance(e, KeyError) else e
        with lock:
            finished += 1
            print(f"error {finished}/{total} {job['name']} could not start: {reason}", flush=True)
        return None
    with lock:
        finished += 1
        secs = round(time.monotonic() - began)
        print(f"done  {finished}/{total} {job['name']} exit={code} {secs}s", flush=True)
    return code


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--max-concurrent", type=int, default=5, help="jobs run at once (default 5)")
    args = parser.parse_args()
    if args.max_concurrent < 1:
        sys.exit("run-queue: --max-concurrent must be at least 1")

    if sys.stdin.isatty():
        sys.exit("run-queue: pass the jobs as JSON Lines on stdin")
    jobs = load_jobs(sys.stdin)
    total = len(jobs)
    with ThreadPoolExecutor(max_workers=args.max_concurrent) as pool:
        codes = list(pool.map(lambda p: run(p[1], p[0], total), enumerate(jobs, 1)))

    unstarted = sum(c is None for c in codes)
    nonzero = sum(c not in (None, 0) for c in codes)
    say(f"summary: {total - unstarted} done, {nonzero} nonzero exit, {unstarted} not started")
    return 1 if unstarted else 0


if __name__ == "__main__":
    sys.exit(main())
