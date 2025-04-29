{
  ctx,
  lib,
  pkgs,
  ...
}@args:
let
in
{
  imports = [ ./base.nix ];

  system.stateVersion = "24.11";

  environment.systemPackages = with pkgs; [
  ];
}
