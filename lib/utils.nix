rec {
  flatten =
    list: builtins.concatLists (builtins.map (x: if builtins.isList x then flatten x else [ x ]) list);

  hasInfix = sub: full: builtins.match ".*${sub}.*" full != null;

  setDotfilesContext =
    { lib, config, ... }:
    {
      options = {
        dotfiles = lib.mkOption {
          type = lib.types.path;
          apply = toString;
          default = "${config.home.homeDirectory}/nixfiles/dotfiles";
          description = "Location of the dotfiles";
        };
      };
    };
}
