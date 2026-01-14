{
  pkgs,
  lib,
  ...
}:
{
  homebrew = lib.optionalAttrs pkgs.stdenv.isDarwin {
    enable = true;
    casks = [
      "ghostty"
    ];
  };
}
