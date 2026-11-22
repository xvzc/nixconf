import json
import os
import subprocess
import sys
import tempfile
import unittest

from helpers import SCRIPTS

QUEUE = str(SCRIPTS / "run-queue.py")


def run_queue(jobs, env=None):
    base = {k: v for k, v in os.environ.items() if k not in ("APT_TEST_SOURCE", "APT_TEST_TARGET")}
    return subprocess.run([sys.executable, QUEUE], input="".join(json.dumps(j) + "\n" for j in jobs),
                          capture_output=True, text=True, env={**base, **(env or {})})


class RunQueueTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)

    def job(self, cmd, **extra):
        d = self.tmp.name
        return {"name": "j", "cwd": d, "cmd": cmd, "stdout": f"{d}/out", "stderr": f"{d}/err", **extra}

    def out(self):
        with open(f"{self.tmp.name}/out") as f:
            return f.read()

    def test_env_is_merged_over_environment(self):
        proc = run_queue([self.job(["/usr/bin/env"], env={"APT_TEST_FIXED": "v1"})], {"APT_TEST_KEEP": "k"})
        self.assertEqual(proc.returncode, 0, proc.stdout)
        lines = self.out().splitlines()
        self.assertIn("APT_TEST_FIXED=v1", lines)
        self.assertIn("APT_TEST_KEEP=k", lines)

    def test_env_from_copies_source_at_launch(self):
        job = self.job(["/usr/bin/env"], env_from={"APT_TEST_TARGET": "APT_TEST_SOURCE"})
        proc = run_queue([job], {"APT_TEST_SOURCE": "fake-value"})
        self.assertEqual(proc.returncode, 0, proc.stdout)
        self.assertIn("APT_TEST_TARGET=fake-value", self.out().splitlines())
        self.assertNotIn("fake-value", proc.stdout)

    def test_missing_env_from_source_fails_the_job(self):
        job = self.job(["/usr/bin/env"], env_from={"APT_TEST_TARGET": "APT_TEST_SOURCE"})
        proc = run_queue([job])
        self.assertEqual(proc.returncode, 1)
        self.assertIn("error 1/1 j could not start: env_from source APT_TEST_SOURCE is not set", proc.stdout)
        self.assertFalse(os.path.exists(f"{self.tmp.name}/out"))

    def test_stdin_file_is_the_job_stdin(self):
        with open(f"{self.tmp.name}/in.txt", "w") as f:
            f.write("hello from file")
        proc = run_queue([self.job(["/bin/cat"], stdin_file=f"{self.tmp.name}/in.txt")])
        self.assertEqual(proc.returncode, 0, proc.stdout)
        self.assertEqual(self.out(), "hello from file")

    def test_old_style_job_has_empty_stdin_and_plain_environment(self):
        proc = run_queue([self.job(["/bin/cat"])])
        self.assertEqual(proc.returncode, 0, proc.stdout)
        self.assertEqual(self.out(), "")
        self.assertIn("done  1/1 j exit=0", proc.stdout)

    def test_invalid_optional_fields_are_rejected(self):
        proc = run_queue([self.job(["/bin/cat"], env=["x"])])
        self.assertEqual(proc.returncode, 1)
        self.assertIn("env and env_from must be objects", proc.stderr)


if __name__ == "__main__":
    unittest.main()
