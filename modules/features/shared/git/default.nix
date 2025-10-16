{
  lib,
  ctx,
  pkgs,
  ...
}:
{
  home-manager.users.${ctx.user} = lib.mkMerge [
    ./user.nix
  ];
}
