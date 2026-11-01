# Renders agent markdown files into a directory of `<name>.md` files. Each file is
# the YAML frontmatter, ../dotfiles/GLOBAL_INSTRUCTIONS.md, a blank line, and the
# agent body.
#   mkAgents { inherit lib pkgs; } {
#     <name> = { enable = true; <extra frontmatter fields>; vars = {...}; };
#   }
# `<name>` must be in `definitions`; its fields are overridden by the caller's. Bodies
# are read from ../dotfiles/agents/<name>.md. `enable` (required boolean) and `vars`
# are reserved: `enable = false` generates nothing, and `vars` values replace `@key@`
# in the agent body only (a key without a placeholder is an error). All other fields
# are the frontmatter. Agents not listed by the caller are not generated.
{ lib, pkgs }:
let
  # Tool-independent agent definitions.
  definitions = {
    architect.description = ''
      Read-only architecture and design advisor. Evaluates structure,
      boundaries, APIs, migrations, tradeoffs, and long-term maintainability.
    '';
    documenter.description = ''
      Documentation writer. Updates README, guides, API docs, examples,
      changelog, migration notes, and other approved documentation within
      scoped authority.
    '';
    engineer.description = ''
      Implementation writer. Modifies files within approved scope, adds or
      updates tests, runs focused validation, fixes own in-scope failures,
      and returns a handoff.
    '';
    orchestrator.description = ''
      User-facing engineering orchestrator and project operator. Default
      user-facing agent; coordinates subagents, owns version control,
      validation, and planning.
    '';
    reviewer.description = ''
      Independent read-only reviewer for code diffs, plans, designs,
      validation adequacy, regressions, and maintainability.
    '';
    scout.description = ''
      Fast read-only scout for codebases and the web. Finds relevant files
      and sources, summarizes current behavior, identifies implementation
      seams, risks, and open questions.
    '';
  };

  bodyDir = ../dotfiles/agents;
  globalInstructions = builtins.readFile ../dotfiles/GLOBAL_INSTRUCTIONS.md;

  # Frontmatter strings are folded to one line.
  fold = s: builtins.replaceStrings [ "\n" ] [ " " ] (lib.trim s);

  # Plain when safe, otherwise a double-quoted (JSON) scalar.
  scalar =
    v0:
    let
      v = if builtins.isString v0 then fold v0 else v0;
    in
    if builtins.isString v then
      if
        builtins.match "[A-Za-z][A-Za-z0-9 ,.()/_-]*" v != null
        && builtins.match ".* " v == null
        && !(builtins.elem v [
          "true"
          "false"
          "null"
          "yes"
          "no"
          "on"
          "off"
        ])
      then
        v
      else
        builtins.toJSON v
    else
      builtins.toJSON v;

  # Lines for a value, with nested blocks indented by two spaces under `ind`.
  render =
    ind: v:
    if builtins.isAttrs v then
      lib.concatLists (
        lib.mapAttrsToList (
          k: x:
          if builtins.isAttrs x || builtins.isList x then
            [ "${ind}${k}:" ] ++ render "${ind}  " x
          else
            [ "${ind}${k}: ${scalar x}" ]
        ) v
      )
    else
      lib.concatMap (
        x:
        if builtins.isAttrs x then
          let
            ls = render "${ind}  " x;
            first = lib.removePrefix "${ind}  " (builtins.head ls);
          in
          [ "${ind}- ${first}" ] ++ builtins.tail ls
        else
          [ "${ind}- ${scalar x}" ]
      ) v;

  # `name` first, then the remaining keys.
  document =
    name: a:
    let
      body = bodyDir + "/${name}.md";
    in
    if !builtins.pathExists body then
      throw "mkAgents: agent '${name}' has no body file ${toString body}"
    else
      lib.concatStringsSep "\n" (
        [
          "---"
          "name: ${scalar name}"
        ]
        ++ render "" (
          removeAttrs a [
            "enable"
            "vars"
          ]
        )
        ++ [
          "---"
          ""
          ""
        ]
      )
      + globalInstructions
      + "\n"
      + expand name (builtins.readFile body) (a.vars or { });

  expand =
    name: body: vars:
    let
      keys = builtins.attrNames vars;
      missing = builtins.filter (k: !lib.hasInfix "@${k}@" body) keys;
    in
    if missing != [ ] then
      throw (
        "mkAgents: agent '${name}' has vars without a matching @key@ placeholder "
        + "in its body: ${lib.concatStringsSep ", " missing}"
      )
    else
      builtins.replaceStrings (map (k: "@${k}@") keys) (map (k: vars.${k}) keys) body;
in
agents:
pkgs.linkFarm "agents" (
  lib.concatMapAttrs (
    name: a:
    if !definitions ? ${name} then
      throw "mkAgents: unknown agent '${name}'"
    else if !builtins.isBool (a.enable or null) then
      throw "mkAgents: agent '${name}' needs enable = true or enable = false"
    else
      let
        text = document name (definitions.${name} // a);
      in
      lib.optionalAttrs a.enable { "${name}.md" = pkgs.writeText "${name}.md" text; }
  ) agents
)
