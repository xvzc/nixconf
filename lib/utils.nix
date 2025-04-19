{
  importListFromDir = dir: let
    files = builtins.readDir dir;

    nixFiles = builtins.filter (
      name:
        (builtins.match ".*\\.nix$" name)
        != null
        && name != "default.nix"
    ) (builtins.attrNames files);
  in
    builtins.map (name: import (dir + "/." + "/${name}")) nixFiles;

  importAttrSetsFromDir = dirPath: args: let
    files = builtins.filter (
      name:
        name
        != "default.nix"
        && builtins.match ".*\\.nix$" name != null
    ) (builtins.attrNames (builtins.readDir dirPath));

    importOne = name: let
      f = import (dirPath + "/${name}");
      val = f args;
    in
      if builtins.isAttrs val
      then val
      else throw "${name} must return an attribute set, but got ${builtins.typeOf val}";

    mergeAttrSets = sets:
      builtins.foldl' (a: b: a // b) {} sets;

    merged = mergeAttrSets (map importOne files);
  in
    merged;

  setDotfilesContext = {
    lib,
    config,
    ...
  }: {
    options = {
      dotfiles = lib.mkOption {
        type = lib.types.path;
        apply = toString;
        default = "${config.home.homeDirectory}/nixfiles/.dotfiles";
        description = "Location of the dotfiles";
      };
    };
  };
}
