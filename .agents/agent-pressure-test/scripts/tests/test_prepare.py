import json
import os
import subprocess
import tempfile
import unittest
from unittest import mock

import helpers
from apt_lib import AptError, batch, prepare

read = helpers.read_text


class PrepareTestCase(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = os.path.join(self.tmp.name, "root")
        self.bundle = str(helpers.make_bundle(os.path.join(self.tmp.name, "bundle")))

    def prepare(self, profile, filters, agents=("developer",), **kw):
        opts = prepare.PrepareOptions(profile=profile, bundle=self.bundle, agents=agents,
                                      filters=filters, root=self.root, **kw)
        return prepare.prepare(opts, say=lambda *_: None)

    def jobs(self, manifest):
        layout = batch.Layout(self.root, manifest["batch"])
        return [json.loads(l) for l in read(layout.jobs_file).splitlines()], layout


class ClaudeProfileTest(PrepareTestCase):
    def test_missing_system_md_fails_prepare(self):
        os.remove(os.path.join(self.bundle, "system.md"))
        with self.assertRaisesRegex(AptError, "system.md"):
            self.prepare("claude", ("developer_behavior_01",))

    def test_dry_run_creates_nothing(self):
        lines = []
        opts = prepare.PrepareOptions(profile="claude", bundle=self.bundle, agents=("developer",),
                                      filters=("developer_behavior_01",), root=self.root, dry_run=True)
        prepare.prepare(opts, say=lines.append)
        self.assertFalse(os.path.exists(self.root))
        self.assertEqual(len(lines), 1)

    def test_agent_must_exist_in_bundle(self):
        os.remove(os.path.join(self.bundle, "claude_agents.json"))
        with self.assertRaises(AptError):
            self.prepare("claude", ("developer_behavior_01",), dry_run=True)


class ProjectTest(PrepareTestCase):
    def git(self, project, *args):
        return subprocess.run(["git", "-C", project, *args], capture_output=True, text=True, check=True).stdout

    def test_fixtures_are_copied_and_committed(self):
        cases = {"developer_behavior_04": ("chore: add legacy chunk helper", "internal/domain/legacy_chunk.go"),
                 "developer_behavior_06": ("docs: add project instructions", None)}
        manifest = self.prepare("claude", tuple(cases))
        for run in manifest["runs"]:
            message, path = cases[run["scenario"].split("-")[0]]
            project = run["project"]
            self.assertEqual(self.git(project, "log", "-1", "--format=%s").strip(), message)
            self.assertEqual(self.git(project, "status", "--short"), "")
            if path:
                self.assertTrue(os.path.isfile(os.path.join(project, path)))

    def test_no_files_scenario_runs_in_scenario_dir(self):
        manifest = self.prepare("claude", ("scout_security_04",), agents=("scout",))
        run = manifest["runs"][0]
        self.assertTrue(run["project"].endswith("work/repo_000"))
        self.assertEqual(os.listdir(run["project"]), [])

    def test_manifest_maps_runs(self):
        manifest = self.prepare("claude", ("common_security_01",), agents=("developer", "scout"), trials=2)
        self.assertEqual([r["name"] for r in manifest["runs"]], [
            "developer_common_security_01-injected-instruction-1", "developer_common_security_01-injected-instruction-2",
            "scout_common_security_01-injected-instruction-1", "scout_common_security_01-injected-instruction-2"])
        r = manifest["runs"][3]
        self.assertEqual((r["run"], r["agent"], r["trial"], r["status"], r["profile"], r["cli"], r["model"]),
                         ("003", "scout", 2, "prepared", "claude", "claude", "haiku"))
        _, layout = self.jobs(manifest)
        self.assertEqual(batch.read_json(layout.manifest_file)["runs"], manifest["runs"])
        # The jobs file and manifest are not under the directory the agents can see.
        self.assertFalse(str(layout.jobs_file).startswith(str(layout.batch_dir) + os.sep))
        self.assertFalse(str(layout.cfg_dir("000")).startswith(str(layout.batch_dir) + os.sep))


class FakeOpencode:
    """Stands in for the opencode subprocess calls; other commands run for real."""

    def __init__(self):
        self.real_run = subprocess.run
        self.calls = []

    def __call__(self, cmd, **kw):
        if cmd[0] != "opencode":
            return self.real_run(cmd, **kw)
        self.calls.append((cmd, kw))
        return subprocess.CompletedProcess(cmd, 0, "opencode vTEST\n", "")


class OpencodeProfileTest(PrepareTestCase):
    def prepare_oc(self, filt, **kw):
        self.fake = FakeOpencode()
        with mock.patch("apt_lib.adapters.opencode.subprocess.run", self.fake):
            return self.prepare("opencode-go", (filt,), model="opencode-go/m1", **kw)

    def config(self, manifest):
        (job,), _ = self.jobs(manifest)
        return json.loads(job["env"]["OPENCODE_CONFIG_CONTENT"])

    def test_config_has_selected_agent_only_with_run_rules_last(self):
        config = self.config(self.prepare_oc("developer_safety_03"))
        self.assertEqual(config["$schema"], "https://opencode.ai/config.json")
        self.assertEqual(config["share"], "disabled")
        self.assertEqual(config["instructions"], ["CLAUDE.md", os.path.join(self.bundle, "system.md")])
        self.assertEqual(list(config["agents"]), ["developer"])
        self.assertEqual(config["agents"]["developer"]["permissions"], [
            {"action": "subagent", "effect": "deny", "resource": "*"},
            {"action": "subagent", "resource": "*", "effect": "deny"},
            {"action": "shell", "resource": "*", "effect": "deny"},
            {"action": "external_directory", "resource": "*", "effect": "deny"}])
        self.assertEqual(config["agents"]["developer"]["system"], "developer prompt")

    def test_no_shell_rule_only_when_requested(self):
        rules = self.config(self.prepare_oc("developer_behavior_01"))["agents"]["developer"]["permissions"]
        self.assertEqual(rules[-2:], [{"action": "subagent", "resource": "*", "effect": "deny"},
                                      {"action": "external_directory", "resource": "*", "effect": "deny"}])
        self.assertNotIn("shell", [r["action"] for r in rules])

    def test_job_env_has_config_content_empty_config_dir_and_claude_code_switch(self):
        manifest = self.prepare_oc("developer_behavior_01")
        (job,), layout = self.jobs(manifest)
        cfg = manifest["runs"][0]["cfg"]
        self.assertEqual(job["cmd"], ["opencode", "run", "--standalone", "--format", "json",
                                      "--agent", "developer", "--model", "opencode-go/m1"])
        self.assertEqual(job["stdin_file"], os.path.join(cfg, "prompt.txt"))
        self.assertIn("Report in XML", read(job["stdin_file"]))
        self.assertEqual(set(job["env"]), {"OPENCODE_CONFIG_CONTENT", "OPENCODE_CONFIG_DIR",
                                           "OPENCODE_DISABLE_CLAUDE_CODE", "PWD"})
        # opencode reads its working directory from PWD, so it must be the project.
        self.assertEqual(job["env"]["PWD"], manifest["runs"][0]["project"])
        self.assertEqual(job["env"]["OPENCODE_CONFIG_DIR"], str(layout.opencode_config_dir))
        self.assertEqual(os.listdir(layout.opencode_config_dir), [])
        self.assertFalse(str(layout.opencode_config_dir).startswith(str(layout.batch_dir) + os.sep))
        self.assertEqual(job["env"]["OPENCODE_DISABLE_CLAUDE_CODE"], "1")
        self.assertNotIn("env_from", job)
        self.assertEqual(os.listdir(cfg), ["prompt.txt"])
        self.assertEqual(manifest["cli_version"], "opencode vTEST")

    def test_only_version_is_called_at_prepare(self):
        self.prepare_oc("developer_behavior_0", trials=2)
        self.assertEqual([c for c, _ in self.fake.calls], [["opencode", "--version", "--standalone"]])

    def test_dry_run_calls_no_opencode(self):
        self.fake = FakeOpencode()
        with mock.patch("apt_lib.adapters.opencode.subprocess.run", self.fake):
            self.prepare("opencode-go", ("developer_behavior_01",), model="x/y", dry_run=True)
        self.assertEqual(self.fake.calls, [])

    def test_model_is_required(self):
        with self.assertRaisesRegex(AptError, "--model"):
            self.prepare("opencode-go", ("developer_behavior_01",), dry_run=True)

    def test_lead_prompt_has_no_report_request(self):
        opts = prepare.PrepareOptions(profile="opencode-go", bundle=self.bundle, agents=("lead",),
                                      filters=("lead_safety_01",), root=self.root, model="x/y")
        with mock.patch("apt_lib.adapters.opencode.subprocess.run", FakeOpencode()):
            m = prepare.prepare(opts, say=lambda *_: None)
        self.assertNotIn("Report in XML", read(os.path.join(m["runs"][0]["cfg"], "prompt.txt")))


if __name__ == "__main__":
    unittest.main()
