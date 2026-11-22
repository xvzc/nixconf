# Shared helpers for Markdown files with YAML frontmatter, used by mk-agents.nix and
# mk-skills.nix.
#
# A source file starts with a `---` frontmatter block of one-line `key: value` fields,
# each value plain or double-quoted (JSON), with at least `name` and `description`;
# structured fields belong in the caller's `frontmatter`. The body follows the closing `---`.
# Each <embed:%key%/> in the body is replaced by embed.<key> without its trailing
# newlines; a placeholder whose key is not in embed is an error.
#
# `label` prefixes error messages, such as "mkAgents: agent 'lead'", and `file` names
# the source file in them.
{ lib }:
let
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

  # A frontmatter value with every string folded, as in the Markdown file.
  foldAll =
    v:
    if builtins.isString v then
      fold v
    else if builtins.isList v then
      map foldAll v
    else if builtins.isAttrs v then
      lib.mapAttrs (_: foldAll) v
    else
      v;

  # Text without its trailing newlines.
  trimNewlines =
    t:
    let
      m = builtins.match "(.*[^\n])\n*" t;
    in
    if m == null then "" else builtins.head m;

  # The file split into { front; body; }, where body starts after the closing `---`.
  parse =
    label: file: text:
    let
      all = lib.splitString "\n" text;
      # Index of the closing `---`, the first one after the opening line.
      close = lib.findFirst (i: builtins.elemAt all i == "---") null (lib.range 1 (lib.length all - 1));
      m =
        if all == [ ] || builtins.head all != "---" || close == null then
          null
        else
          [
            (lib.concatStringsSep "\n" (lib.sublist 1 (close - 1) all))
            (lib.concatStringsSep "\n" (lib.drop (close + 1) all))
          ];
      field =
        line:
        let
          kv = builtins.match "([A-Za-z][A-Za-z0-9_-]*): (.+)" line;
          raw = builtins.elemAt kv 1;
        in
        if kv == null then
          throw "${label} ${file} frontmatter line is not a one-line `key: value`: ${line}"
        else
          {
            name = builtins.head kv;
            value = if lib.hasPrefix "\"" raw then builtins.fromJSON raw else raw;
          };
      lines = builtins.filter (l: l != "") (lib.splitString "\n" (builtins.head m));
      pairs = map field lines;
      keys = map (p: p.name) pairs;
    in
    if m == null then
      throw "${label} ${file} must start with a `---` frontmatter block"
    else if lib.length (lib.unique keys) != lib.length keys then
      throw "${label} ${file} frontmatter repeats a key"
    else
      {
        front = builtins.listToAttrs pairs;
        body = builtins.elemAt m 1;
      };

  embedPattern = "<embed:%([A-Za-z0-9_]+)%/>";

  # Keys of the <embed:%key%/> placeholders in a body.
  embedKeys =
    body: map builtins.head (builtins.filter builtins.isList (builtins.split embedPattern body));

  expand =
    label: body: embed:
    let
      parts = builtins.split embedPattern body;
      undefined = builtins.filter (k: !(embed ? ${k})) (lib.unique (embedKeys body));
    in
    if undefined != [ ] then
      throw (
        "${label} has <embed:%key%/> placeholders without a matching embed: "
        + lib.concatStringsSep ", " undefined
      )
    else
      lib.concatStrings (
        map (p: if builtins.isList p then trimNewlines embed.${builtins.head p} else p) parts
      );
in
{
  inherit foldAll embedKeys;

  # Whether an entry is enabled: `enable` defaults to true and must be a bool when set.
  isEnabled =
    label: a:
    let
      e = a.enable or true;
    in
    if builtins.isBool e then e else throw "${label} needs enable = true or enable = false";

  # Throws unless every attribute of `a` is in `allowed`.
  checkAttrs =
    label: allowed: a:
    let
      unknown = builtins.filter (k: !builtins.elem k allowed) (builtins.attrNames a);
    in
    if unknown != [ ] then
      throw "${label} has unknown attributes: ${lib.concatStringsSep ", " unknown}"
    else
      a;

  # Throws if an embed key is used by no rendered body.
  checkEmbedsUsed =
    who: embed: bodies:
    let
      used = lib.unique (lib.concatMap embedKeys bodies);
      unused = builtins.filter (k: !builtins.elem k used) (builtins.attrNames embed);
    in
    if unused != [ ] then
      throw "${who}: embed keys used by no enabled entry: ${lib.concatStringsSep ", " unused}"
    else
      true;

  # { front; body; expanded; text; }: the frontmatter fields with `frontmatter`
  # applied, the body before and after expansion, and the rendered Markdown file. A key
  # in `frontmatter` replaces the file's value in place; other keys follow the file's
  # fields. `name` cannot be replaced.
  renderFile =
    {
      label,
      file,
      name,
      source,
      frontmatter ? { },
      embed ? { },
    }:
    let
      parsed = parse label file source;
      own = parsed.front;
      front = own // frontmatter;
      expanded = expand label parsed.body embed;
    in
    if !(own ? name) || !(own ? description) then
      throw "${label} ${file} frontmatter needs both name and description"
    else if own.name != name then
      throw "${label} ${file} has name '${toString own.name}'"
    else if frontmatter ? name then
      throw "${label} cannot replace `name` in frontmatter"
    else
      {
        inherit front expanded;
        inherit (parsed) body;
        text =
          lib.concatStringsSep "\n" (
            [ "---" ]
            ++ render "" { inherit (front) name; }
            ++ render "" { inherit (front) description; }
            ++ render "" (
              removeAttrs (builtins.intersectAttrs own front) [
                "name"
                "description"
              ]
            )
            ++ render "" (removeAttrs frontmatter (builtins.attrNames own))
            ++ [ "---" ]
          )
          + "\n"
          + expanded;
      };
}
