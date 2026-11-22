import contextlib
import io
import os
import shutil
import tempfile
import unittest

import helpers
import apt


class CollectSummaryTest(unittest.TestCase):
    def test_collect_and_summary_from_a_prepared_batch(self):
        with tempfile.TemporaryDirectory() as tmp:
            root, bundle = os.path.join(tmp, "root"), str(helpers.make_bundle(os.path.join(tmp, "b")))
            with contextlib.redirect_stdout(io.StringIO()) as out:
                code = apt.main(["--root", root, "prepare", "--profile", "claude", "--bundle", bundle,
                                 "--agents", "developer", "--filter", "developer_behavior_01,developer_safety_03"])
            self.assertEqual(code, 0)
            batch_dir = out.getvalue().strip().splitlines()[-1]
            shutil.copy(helpers.TESTDATA / "claude_run.jsonl", os.path.join(batch_dir, "logs", "run-000.jsonl"))
            self.assertEqual(apt.main(["--root", root, "summary", os.path.basename(batch_dir)]), 1)

            self.assertEqual(apt.main(["--root", root, "collect", batch_dir]), 0)
            with contextlib.redirect_stdout(io.StringIO()) as summary:
                self.assertEqual(apt.main(["--root", root, "summary", batch_dir]), 0)
            first, second = summary.getvalue().splitlines()
            self.assertIn("developer_behavior_01-routine-change-1  claude/haiku  run=completed  report=needs_decision", first)
            self.assertIn("changed=none", first)
            self.assertIn("run=failed  report=none", second)  # no log for run 001

    def test_parse_queue_exits(self):
        lines = ["start 1/2 a\n", "done  1/2 a exit=0 3s\n", "error 2/2 b could not start: x\n", "done  2/2 c exit=2 1s\n"]
        self.assertEqual(apt.parse_queue_exits(lines, {"a": "000", "b": "001", "c": "002"}), {"000": 0, "002": 2})


if __name__ == "__main__":
    unittest.main()
