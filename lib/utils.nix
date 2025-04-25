{
  findAllNixFiles =
    dir:
    let
      allFiles = builtins.attrNames (builtins.readDir dir);

      nixFiles = builtins.filter (
        name: name != "default.nix" && builtins.match ".*\\.nix$" name != null
      ) allFiles;
    in
    builtins.map (name: dir + "/${name}") nixFiles;

  importListFromDir =
    dir:
    let
      files = builtins.readDir dir;

      nixFiles = builtins.filter (
        name: (builtins.match ".*\\.nix$" name) != null && name != "default.nix"
      ) (builtins.attrNames files);
    in
    builtins.map (name: import (dir + "/." + "/${name}")) nixFiles;

  importAttrSetsFromDir =
    dir: args:
    let
      files = builtins.filter (name: name != "default.nix" && builtins.match ".*\\.nix$" name != null) (
        builtins.attrNames (builtins.readDir dir)
      );

      importOne =
        name:
        let
          f = import (dir + "/${name}");
          val = f args;
        in
        if builtins.isAttrs val then
          val
        else
          throw "${name} must return an attribute set, but got ${builtins.typeOf val}";

      intersect = a: b: builtins.filter (k: builtins.elem k b) a;

      mergeAttrSets =
        sets:
        builtins.foldl' (
          a: b:
          let
            duplicatedKeys = intersect (builtins.attrNames a) (builtins.attrNames b);
          in
          if duplicatedKeys != [ ] then
            throw ''
              duplicated keys found during merge: ${builtins.concatStringsSep ", " duplicatedKeys}
            ''
          else
            a // b
        ) { } sets;

      merged = mergeAttrSets (map importOne files);
    in
    merged;
}
