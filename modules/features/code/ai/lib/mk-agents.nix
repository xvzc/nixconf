# Renders every agent in ../dotfiles/agents into a directory of `<name>.md` files,
# plus claude_agents.json, the same agents in the format of `claude --agents`.
# The result also has `bundle`, a directory with those files plus opencode_agents.json,
# the same agents as opencode config (`{ "agents": { <name>: ... } }`), and system.md,
# a copy of ../dotfiles/system.md. The result itself, which is what gets deployed, has
# none of the extra files.
#   mkAgents { inherit lib pkgs; } {
#     embed = { ... };               # optional; fills <embed:%key%/> placeholders
#     overrides.<name> = {           # optional; only for agents that need a change
#       enable = true;               # optional, default true; false generates nothing
#       frontmatter = { ... };       # optional; replaces or adds frontmatter fields
#     };
#   }
# An override for an agent with no file, and any other attribute, is an error.
#
# Each agent is read from ../dotfiles/agents/<name>.md, in the format render-markdown.nix
# describes, with `name` equal to `<name>`. An embed key that no enabled agent uses is
# an error.
#
# In claude_agents.json, each agent is its frontmatter fields without `name`, with
# strings folded as in the Markdown file, plus `prompt`, the body. String `tools` and
# `disallowedTools` become lists.
{ lib, pkgs }:
let
  md = import ./render-markdown.nix { inherit lib; };

  # Claude Code tool name to opencode permission action.
  actionOf = {
    Read = "read";
    Grep = "grep";
    Glob = "glob";
    Bash = "shell";
    WebSearch = "websearch";
    WebFetch = "webfetch";
    Edit = "edit";
    Write = "edit";
    NotebookEdit = "edit";
    Agent = "subagent";
  };

  rule = action: resource: effect: { inherit action resource effect; };

  # Distinct actions of the tools, in order.
  actions =
    label: tools:
    lib.unique (
      map (
        t:
        actionOf.${t}
          or (throw "${label}: tool '${t}' has no opencode action; known tools: ${lib.concatStringsSep ", " (builtins.attrNames actionOf)}")
      ) tools
    );

  envRules = [
    (rule "read" "*.env" "ask")
    (rule "read" "*.env.*" "ask")
    (rule "read" "*.env.example" "allow")
  ];

  # { label, def }: the agent's opencode definition, an entry of `agents` in opencode's
  # config, from `def`, its claude_agents.json entry. `description` and `prompt` become
  # `description` and `system`, and `mode` is "primary". Other fields are dropped, except
  # `tools` and `disallowedTools`, which become `permissions`, an ordered list of rules in
  # which the last matching rule wins:
  #   - `tools` (allowlist): deny everything, allow the actions of the listed tools, allow
  #     external_directory, then opencode's default `.env` rules, which the deny would
  #     otherwise remove.
  #   - `disallowedTools`: a deny per action, after the rules above.
  # An agent with neither has no `permissions`, so opencode's defaults apply.
  opencodeAgent =
    { label, def }:
    let
      allowlist = lib.optionals (def ? tools) (
        [ (rule "*" "*" "deny") ]
        ++ map (a: rule a "*" "allow") (actions label def.tools)
        ++ [ (rule "external_directory" "*" "allow") ]
        ++ envRules
      );
      denylist = map (a: rule a "*" "deny") (actions label (def.disallowedTools or [ ]));
      permissions = allowlist ++ denylist;
    in
    {
      inherit (def) description;
      mode = "primary";
      system = def.prompt;
    }
    // lib.optionalAttrs (permissions != [ ]) { inherit permissions; };

  agentsDir = ../dotfiles/agents;

  # Comma-separated tool names as a list.
  toolList = v: if builtins.isString v then map lib.trim (lib.splitString "," v) else v;

  allowedAttrs = [
    "enable"
    "frontmatter"
  ];

  # { text; def; body; }: the Markdown file, the agent's claude_agents.json entry, and
  # its body before expansion.
  document =
    name: a: embed:
    let
      label = "mkAgents: agent '${name}'";
      doc = md.renderFile {
        inherit label name embed;
        file = "${name}.md";
        source = builtins.readFile (agentsDir + "/${name}.md");
        frontmatter = a.frontmatter or { };
      };
      fields = md.foldAll (removeAttrs doc.front [ "name" ]);
    in
    builtins.seq (md.checkAttrs label allowedAttrs a) {
      inherit (doc) body text;
      def =
        fields
        // lib.mapAttrs (_: toolList) (
          lib.filterAttrs (k: _: k == "tools" || k == "disallowedTools") fields
        )
        // {
          prompt = lib.removePrefix "\n" doc.expanded;
        };
    };
in
{
  embed ? { },
  overrides ? { },
}:
let
  names = map (lib.removeSuffix ".md") (
    builtins.attrNames (
      lib.filterAttrs (f: t: t == "regular" && lib.hasSuffix ".md" f) (builtins.readDir agentsDir)
    )
  );
  missing = builtins.filter (n: !builtins.elem n names) (builtins.attrNames overrides);

  docs = lib.concatMapAttrs (
    name: a:
    lib.optionalAttrs (md.isEnabled "mkAgents: agent '${name}'" a) {
      ${name} = document name a embed;
    }
  ) (lib.genAttrs names (n: overrides.${n} or { }));
in
if missing != [ ] then
  throw "mkAgents: overrides for agents with no ${toString agentsDir}/<name>.md: ${lib.concatStringsSep ", " missing}"
else
  builtins.seq (md.checkEmbedsUsed "mkAgents" embed (map (d: d.body) (builtins.attrValues docs))) (
    let
      files =
        lib.mapAttrs' (name: d: lib.nameValuePair "${name}.md" (pkgs.writeText "${name}.md" d.text)) docs
        // {
          "claude_agents.json" = pkgs.writeText "claude_agents.json" (
            builtins.toJSON (lib.mapAttrs (_: d: d.def) docs)
          );
        };
    in
    pkgs.linkFarm "agents" files
    // {
      bundle = pkgs.linkFarm "agents-bundle" (
        files
        // {
          "opencode_agents.json" = pkgs.writeText "opencode_agents.json" (
            builtins.toJSON {
              agents = lib.mapAttrs (
                name: d:
                opencodeAgent {
                  label = "mkAgents: agent '${name}'";
                  inherit (d) def;
                }
              ) docs;
            }
          );
          "system.md" = ../dotfiles/system.md;
        }
      );
    }
  )
