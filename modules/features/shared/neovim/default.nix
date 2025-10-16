{
  lib,
  pkgs,
  ctx,
  ...
}:
{
  home-manager.users.${ctx.user} = lib.mkMerge [
    ./user.nix
  ];
}
