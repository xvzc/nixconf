{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
{
  options.wallpaper = {
    source = mkOption {
      type = types.nullOr types.path;
      default = null;
    };
  };
}
