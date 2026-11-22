# Renders every skill in ../dotfiles/skills into a directory of `<name>/` skill
# directories.
#   mkSkills { inherit lib pkgs; } {
#     embed = { ... };               # optional; fills <embed:%key%/> placeholders
#     overrides.<name> = {           # optional; only for skills that need a change
#       enable = true;               # optional, default true; false generates nothing
#       frontmatter = { ... };       # optional; replaces or adds frontmatter fields
#     };
#   }
# An override for a skill with no directory, and any other attribute, is an error.
#
# Each skill is read from ../dotfiles/skills/<name>/SKILL.md, in the format
# render-markdown.nix describes, with `name` equal to `<name>`. A skill directory without
# SKILL.md is an error, and so is an embed key that no enabled skill uses. Embeds are
# expanded in SKILL.md only; the skill's other files are copied unchanged.
#
# The result's `byNames.<name>` is `<name>` for each enabled skill, so a reference such
# as an agent's `skills` list fails to evaluate when it names a missing or disabled
# skill.
{ lib, pkgs }:
let
  md = import ./render-markdown.nix { inherit lib; };

  skillsDir = ../dotfiles/skills;

  allowedAttrs = [
    "enable"
    "frontmatter"
  ];

  # { body; files; }: the SKILL.md body before expansion, and the skill's output files
  # as { "<name>/<path>" = <store path>; }.
  document =
    name: a: embed:
    let
      label = "mkSkills: skill '${name}'";
      dir = skillsDir + "/${name}";
      doc = md.renderFile {
        inherit label name embed;
        file = "${name}/SKILL.md";
        source = builtins.readFile (dir + "/SKILL.md");
        frontmatter = a.frontmatter or { };
      };
      rel = f: lib.removePrefix "${toString dir}/" (toString f);
      others = builtins.filter (f: rel f != "SKILL.md") (lib.filesystem.listFilesRecursive dir);
    in
    builtins.seq (md.checkAttrs label allowedAttrs a) {
      inherit (doc) body;
      files = builtins.listToAttrs (map (f: lib.nameValuePair "${name}/${rel f}" f) others) // {
        "${name}/SKILL.md" = pkgs.writeText "${name}-SKILL.md" doc.text;
      };
    };
in
{
  embed ? { },
  overrides ? { },
}:
let
  names = builtins.attrNames (lib.filterAttrs (_: t: t == "directory") (builtins.readDir skillsDir));
  missing = builtins.filter (n: !builtins.elem n names) (builtins.attrNames overrides);

  docs = lib.concatMapAttrs (
    name: a:
    let
      label = "mkSkills: skill '${name}'";
    in
    if !builtins.pathExists (skillsDir + "/${name}/SKILL.md") then
      throw "${label} needs ${toString skillsDir}/${name}/SKILL.md"
    else
      lib.optionalAttrs (md.isEnabled label a) { ${name} = document name a embed; }
  ) (lib.genAttrs names (n: overrides.${n} or { }));
in
if missing != [ ] then
  throw "mkSkills: overrides for skills with no ${toString skillsDir}/<name>/ directory: ${lib.concatStringsSep ", " missing}"
else
  builtins.seq (md.checkEmbedsUsed "mkSkills" embed (map (d: d.body) (builtins.attrValues docs))) (
    (pkgs.linkFarm "skills" (lib.concatMapAttrs (_: d: d.files) docs)).overrideAttrs (old: {
      passthru = (old.passthru or { }) // {
        byNames = lib.mapAttrs (name: _: name) docs;
      };
    })
  )
