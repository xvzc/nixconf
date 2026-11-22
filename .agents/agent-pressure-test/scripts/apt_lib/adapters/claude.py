"""Claude Code adapter."""

from .. import AptError
from . import Adapter, Job, failure_status, read_events, text_before_status, tool_call


class ClaudeAdapter(Adapter):
    cli = "claude"
    supported_tokens = frozenset({"no-shell"})

    def preflight(self):
        for name in ("claude_agents.json", "system.md"):
            if not (self.bundle / name).is_file():
                raise AptError(f"bundle {self.bundle} has no {name}")

    def make_job(self, spec):
        disallowed = ["Agent", "Monitor"] + (["Bash"] if "no-shell" in spec.tokens else [])
        return Job([
            "claude", "-p",
            # Skips the user's CLAUDE.md, hooks and plugins; the bundle's global instructions
            # are appended to the system prompt instead.
            "--setting-sources", "project,local",
            "--append-system-prompt-file", str(self.bundle / "system.md"),
            "--agents", str(self.bundle / "claude_agents.json"),
            "--agent", spec.agent, "--model", spec.model, "--permission-mode", "auto",
            "--strict-mcp-config", "--no-session-persistence",
            "--disallowedTools", ",".join(disallowed),
            "--output-format", "stream-json", "--verbose", spec.prompt,
        ])

    @staticmethod
    def normalize(log_path, agent):
        events, bad = read_events(log_path)
        out = {"cli_version": None, "texts": [], "tool_calls": [], "report": None,
               "report_found": False, "text_before_status": None, "cost_usd": None, "errors": [],
               "events": len(events)}
        by_id, results = {}, []
        for ev in events:
            kind = ev.get("type")
            if kind == "system" and ev.get("subtype") == "init":
                out["cli_version"] = ev.get("claude_code_version")
            elif kind == "assistant":
                for block in ev.get("message", {}).get("content", []):
                    if block.get("type") == "text" and block.get("text", "").strip():
                        out["texts"].append(block["text"].strip())
                    elif block.get("type") == "tool_use":
                        call = tool_call(block.get("name", ""), block.get("input", {}))
                        by_id[block.get("id")] = call
                        out["tool_calls"].append(call)
            elif kind == "user":
                content = ev.get("message", {}).get("content")
                for block in content if isinstance(content, list) else []:
                    call = by_id.get(block.get("tool_use_id"))
                    if block.get("type") == "tool_result" and call and block.get("is_error"):
                        text = _result_text(block.get("content"))
                        call["status"] = failure_status(text)
                        call["error"] = text
            elif kind == "result":
                results.append(ev.get("result") or "")
                if ev.get("total_cost_usd") is not None:
                    out["cost_usd"] = ev["total_cost_usd"]
                if ev.get("is_error"):
                    out["errors"].append(f"result error: {ev.get('subtype')}: {ev.get('result')}")
        if bad:
            out["errors"].append(f"{bad} unparseable log line(s)")
        reports = results if agent == "lead" else [r for r in results if "<status>" in r]
        if reports:
            out["report"], out["report_found"] = reports[-1], True
        out["text_before_status"] = text_before_status(out["report"])
        return out


def _result_text(content):
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        return "\n".join(b.get("text", "") for b in content if isinstance(b, dict))
    return "" if content is None else str(content)
