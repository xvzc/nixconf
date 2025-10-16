{
  lib,
  pkgs,
  ctx,
  config,
  ...
}:
{
  imports = [
    ./host.nix
  ];

  home-manager.users.${ctx.user} = lib.mkMerge [
    ./user.nix
  ];
}
