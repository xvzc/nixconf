import json
import pathlib
import sys

SCRIPTS = pathlib.Path(__file__).resolve().parents[1]
APT_DIR = SCRIPTS.parent
TESTDATA = pathlib.Path(__file__).resolve().parent / "testdata"
sys.path.insert(0, str(SCRIPTS))


def make_bundle(directory):
    """A fake agents bundle with the same file layout as `make agents` output."""
    directory = pathlib.Path(directory)
    directory.mkdir(parents=True, exist_ok=True)
    names = ["architect", "developer", "documenter", "lead", "reviewer", "scout"]
    (directory / "system.md").write_text("global instructions\n")
    (directory / "claude_agents.json").write_text(
        json.dumps({n: {"description": n, "prompt": n, "tools": []} for n in names}))
    agents = {n: {"description": n, "mode": "primary", "system": f"{n} prompt"} for n in names}
    agents["developer"]["permissions"] = [{"action": "subagent", "effect": "deny", "resource": "*"}]
    (directory / "opencode_agents.json").write_text(json.dumps({"agents": agents}))
    return directory


def read_text(path):
    with open(path) as f:
        return f.read()
