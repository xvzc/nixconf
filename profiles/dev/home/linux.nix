{
  ctx,
  lib,
  pkgs,
  ...
}@args:
{
  imports = [ ./base.nix ];

  home.packages = with pkgs; [
  ];
}
