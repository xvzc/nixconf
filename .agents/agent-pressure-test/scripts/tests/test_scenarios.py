import os
import tempfile
import unittest

import helpers
from apt_lib import AptError, scenarios

APT = str(helpers.APT_DIR)


class ParseTest(unittest.TestCase):
    def test_every_current_scenario_parses(self):
        files = []
        for base, _, names in os.walk(os.path.join(APT, "scenarios")):
            if "deferred" in base.split(os.sep):
                continue
            files += [os.path.join(base, n) for n in names if n.endswith(".md")]
        self.assertGreater(len(files), 20)
        for path in files:
            s = scenarios.parse_scenario(path)
            self.assertTrue(s.prompt, path)
            if s.has_project:
                self.assertNotIn("--dest", s.setup_flags)
            if s.fixture_id:
                self.assertTrue(os.path.isdir(os.path.join(APT, "fixtures", s.fixture_id)), path)

    def test_fixture_and_commit_detection_with_wrapped_phrase(self):
        d = os.path.join(APT, "scenarios", "per-agent", "developer")
        s4 = scenarios.parse_scenario(os.path.join(d, "developer_behavior_04-surgical-fix.md"))
        self.assertEqual(s4.fixture_id, "developer_behavior_04-surgical-fix")
        self.assertEqual(s4.commit_message, "chore: add legacy chunk helper")
        self.assertEqual(s4.setup_flags, ("--git", "--failing-chunk-test"))
        s6 = scenarios.parse_scenario(os.path.join(d, "developer_behavior_06-dependent-checks.md"))
        self.assertEqual(s6.fixture_id, "developer_behavior_06-dependent-checks")
        self.assertEqual(s6.commit_message, "docs: add project instructions")

    def test_no_files_scenario_has_no_project(self):
        s = scenarios.parse_scenario(os.path.join(APT, "scenarios/per-agent/scout/scout_security_04-failed-tool-bypass.md"))
        self.assertFalse(s.has_project)
        self.assertEqual(s.setup_flags, ())

    def test_run_options_tokens(self):
        s = scenarios.parse_scenario(os.path.join(APT, "scenarios/per-agent/developer/developer_safety_03-unverified-pass.md"))
        self.assertEqual(s.run_options, ("no-shell",))

    def test_unknown_run_option_token_fails(self):
        with tempfile.TemporaryDirectory() as d:
            path = os.path.join(d, "developer_x_01-y.md")
            with open(path, "w") as f:
                f.write("## Setup\n\nNo files.\n\n## Run Options\n\n- `no-net`: x\n\n## Prompt\n\n```text\nhi\n```\n")
            with self.assertRaisesRegex(AptError, "no-net"):
                scenarios.parse_scenario(path)

    def test_prompt_template(self):
        s = scenarios.Scenario("a_b_01-c", "a", "", False, (), "", "", "ctx", "do it", ())
        self.assertEqual(scenarios.compose_prompt(s, "developer"), "ctx\n\ndo it\n\n" + scenarios.REPORT_REQUEST)
        s = scenarios.Scenario("a_b_01-c", "a", "", False, (), "", "", "", "do it", ())
        self.assertEqual(scenarios.compose_prompt(s, "developer"), "do it\n\n" + scenarios.REPORT_REQUEST)
        self.assertEqual(scenarios.compose_prompt(s, "lead"), "do it")


class SelectTest(unittest.TestCase):
    def test_common_scenarios_expand_per_agent(self):
        pairs = scenarios.select(APT, ["developer", "scout"], ["common_"])
        got = sorted((a, s.id) for s, a in pairs)
        self.assertEqual(len(got), 6)
        self.assertEqual({a for a, _ in got}, {"developer", "scout"})
        names = {scenarios.run_name(s, a, 1) for s, a in pairs}
        self.assertIn("scout_common_security_03-ethical-pressure-1", names)

    def test_per_agent_scenarios_run_only_with_their_owner(self):
        pairs = scenarios.select(APT, ["scout"])
        for s, a in pairs:
            self.assertIn(s.owner, ("scout", "common"))
            self.assertEqual(a, "scout")
        self.assertIn("developer_safety_01-missing-dependency-1",
                      {scenarios.run_name(s, a, 1) for s, a in scenarios.select(APT, ["developer"])})

    def test_deferred_is_never_selected(self):
        self.assertFalse([s for s, _ in scenarios.select(APT) if "engineer" in s.owner])

    def test_unknown_agent_fails(self):
        with self.assertRaises(AptError):
            scenarios.select(APT, ["nobody"])


if __name__ == "__main__":
    unittest.main()
