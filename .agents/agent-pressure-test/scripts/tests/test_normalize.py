import json
import os
import tempfile
import unittest

import helpers
from apt_lib import records
from apt_lib.adapters.claude import ClaudeAdapter
from apt_lib.adapters.opencode import OpencodeAdapter

RUN = {"run": "000", "name": "n-1", "scenario": "s", "agent": "developer", "trial": 1, "profile": "p",
       "cli": "claude", "model": "m", "status": "prepared", "log": "l", "project": "/nonexistent"}


class ClaudeNormalizerTest(unittest.TestCase):
    """Uses a real Claude Code log (testdata/claude_run.jsonl)."""

    def setUp(self):
        self.parsed = ClaudeAdapter.normalize(str(helpers.TESTDATA / "claude_run.jsonl"), "developer")

    def test_header_report_and_cost(self):
        p = self.parsed
        self.assertEqual(p["cli_version"], "2.1.311")
        self.assertTrue(p["report_found"])
        self.assertTrue(p["report"].startswith("<status>needs_decision</status>"))
        self.assertAlmostEqual(p["cost_usd"], 0.01377424)
        self.assertEqual(p["errors"], [])

    def test_texts_and_tool_calls(self):
        p = self.parsed
        self.assertEqual(p["texts"][0], "I'll start by finding where fees and settlements handle currencies.")
        self.assertEqual(len(p["tool_calls"]), 8)
        first = p["tool_calls"][0]
        self.assertEqual((first["name"], first["native_name"], first["status"]), ("shell", "Bash", "ok"))
        self.assertTrue(first["command"].startswith("git status"))
        self.assertTrue(all(c["name"] == "shell" for c in p["tool_calls"]))

    def test_lead_report_is_last_result(self):
        self.assertEqual(ClaudeAdapter.normalize(str(helpers.TESTDATA / "claude_run.jsonl"), "lead")["report"],
                         self.parsed["report"])

    def test_record_and_summary_line(self):
        rec = records.build_record(RUN, self.parsed, 0)
        self.assertEqual((rec["schema"], rec["status"], rec["cli_version"]), (1, "completed", "2.1.311"))
        self.assertEqual(set(rec), {"schema", "run", "name", "scenario", "agent", "trial", "cli", "cli_version",
                                    "profile", "model", "status", "skip_reason", "exit_code", "report",
                                    "report_found", "text_before_status", "texts", "tool_calls", "cost_usd", "errors", "log", "project"})
        line = records.summary_line(rec, ["M a.go"])
        self.assertIn("report=needs_decision", line)
        self.assertIn("text-before-status=no", line)
        self.assertIn("changed=M a.go", line)
        self.assertIn("cost=$0.0138", line)

    def test_text_before_status_means_the_report_message_has_a_preamble(self):
        self.assertFalse(self.parsed["text_before_status"])  # earlier narration does not count
        events = [{"type": "result", "result": "  Here is my report.\n<status>successful</status>"}]
        with tempfile.TemporaryDirectory() as d:
            path = os.path.join(d, "l.jsonl")
            with open(path, "w") as f:
                f.write(json.dumps(events[0]) + "\n")
            p = ClaudeAdapter.normalize(path, "developer")
        self.assertTrue(p["report_found"])
        self.assertTrue(p["text_before_status"])
        rec = records.build_record(RUN, p, 0)
        self.assertTrue(rec["text_before_status"])
        self.assertIn("text-before-status=yes", records.summary_line(rec, []))

    def test_missing_log_is_a_failed_record(self):
        parsed = ClaudeAdapter.normalize("/nonexistent/log", "developer")
        self.assertEqual(records.build_record(RUN, parsed, None)["status"], "failed")

    def test_denied_and_error_tool_results(self):
        events = [
            {"type": "assistant", "message": {"content": [
                {"type": "tool_use", "id": "a", "name": "Bash", "input": {"command": "curl x"}},
                {"type": "tool_use", "id": "b", "name": "Read", "input": {"file_path": "/x"}}]}},
            {"type": "user", "message": {"content": [
                {"type": "tool_result", "tool_use_id": "a", "is_error": True,
                 "content": "Permission for this action has been denied."},
                {"type": "tool_result", "tool_use_id": "b", "is_error": True, "content": [{"type": "text", "text": "nope"}]}]}},
            {"type": "result", "result": "<status>blocked</status>", "total_cost_usd": 1.5},
        ]
        with tempfile.TemporaryDirectory() as d:
            path = os.path.join(d, "l.jsonl")
            with open(path, "w") as f:
                f.write("".join(json.dumps(e) + "\n" for e in events) + "not json\n")
            p = ClaudeAdapter.normalize(path, "developer")
        self.assertEqual([c["status"] for c in p["tool_calls"]], ["denied", "error"])
        self.assertEqual(p["tool_calls"][1]["error"], "nope")
        self.assertEqual(p["errors"], ["1 unparseable log line(s)"])


class OpencodeNormalizerTest(unittest.TestCase):
    """Uses a synthetic log (testdata/opencode_synthetic.jsonl) written from the documented
    event shapes, not a capture from a live opencode run."""

    path = str(helpers.TESTDATA / "opencode_synthetic.jsonl")

    def test_parts(self):
        p = OpencodeAdapter.normalize(self.path, "developer")
        self.assertEqual(p["texts"], ["Looking at the code.", "<status>successful</status>\n\n<summary>Done.</summary>",
                                      "Anything else?"])
        self.assertTrue(p["report_found"])
        self.assertTrue(p["report"].startswith("<status>successful</status>"))
        self.assertAlmostEqual(p["cost_usd"], 0.03)
        self.assertEqual(p["errors"], ["provider hiccup"])
        self.assertIsNone(p["cli_version"])

    def test_tool_calls(self):
        calls = OpencodeAdapter.normalize(self.path, "developer")["tool_calls"]
        self.assertEqual([(c["name"], c["native_name"], c["status"]) for c in calls], [
            ("shell", "shell", "ok"), ("read", "read", "error"), ("webfetch", "webfetch", "denied"),
            ("edit", "edit", "denied"), ("other", "execute", "ok")])
        self.assertEqual(calls[0]["command"], "git status")
        self.assertEqual(calls[1]["error"], "file not found")
        self.assertIsNone(calls[1]["command"])

    def test_real_opencode_log(self):
        """Uses a real opencode 2.1.4 run (testdata/opencode_run.jsonl)."""
        p = OpencodeAdapter.normalize(str(helpers.TESTDATA / "opencode_run.jsonl"), "developer")
        self.assertEqual([c["native_name"] for c in p["tool_calls"]],
                         ["grep", "shell", "read", "shell", "shell", "shell", "shell", "shell"])
        self.assertEqual([c["name"] for c in p["tool_calls"]],
                         ["grep", "shell", "read", "shell", "shell", "shell", "shell", "shell"])
        self.assertEqual(p["tool_calls"][1]["command"], "ls /Users/kazusa/nixconf")
        self.assertTrue(all(c["status"] == "ok" for c in p["tool_calls"]))
        self.assertTrue(p["report_found"])
        self.assertTrue(p["report"].startswith("<status>needs_decision</status>"))
        self.assertFalse(p["text_before_status"])
        self.assertAlmostEqual(p["cost_usd"], 0.0011416 + 0.00196389 + 0.00123734 + 0.00085126 + 0.0009651
                               + 0.0011662 + 0.00174123)
        self.assertEqual(p["errors"], [])

    def test_text_before_status_checks_the_report_message_only(self):
        p = OpencodeAdapter.normalize(self.path, "developer")
        self.assertFalse(p["text_before_status"])  # "Looking at the code." is another message
        events = [{"type": "text", "part": {"id": "a", "messageID": "m", "text": "Intro."}},
                  {"type": "text", "part": {"id": "b", "messageID": "m", "text": "<status>blocked</status>"}}]
        with tempfile.TemporaryDirectory() as d:
            path = os.path.join(d, "l.jsonl")
            with open(path, "w") as f:
                f.write("".join(json.dumps(e) + "\n" for e in events))
            p = OpencodeAdapter.normalize(path, "developer")
        self.assertEqual(p["report"], "Intro.\n<status>blocked</status>")
        self.assertTrue(p["text_before_status"])

    def test_lead_report_is_last_message(self):
        p = OpencodeAdapter.normalize(self.path, "lead")
        self.assertEqual(p["report"], "Anything else?")

    def test_record_status_failed_on_error_event_and_version_from_manifest(self):
        parsed = OpencodeAdapter.normalize(self.path, "developer")
        rec = records.build_record({**RUN, "cli": "opencode", "cli_version": "opencode v2.1.4"}, parsed, 0)
        self.assertEqual((rec["status"], rec["cli_version"]), ("failed", "opencode v2.1.4"))

    def test_skipped_record(self):
        rec = records.build_record({**RUN, "status": "skipped", "skip_reason": "why"}, None, None)
        self.assertEqual((rec["status"], rec["skip_reason"]), ("skipped", "why"))
        self.assertIn("skipped: why", records.summary_line(rec, None))


if __name__ == "__main__":
    unittest.main()
