{
  ctx,
  lib,
  ...
}:
{
  imports = [
    ./overlays.nix
    { home-manager.users.${ctx.user} = lib.mkMerge [ ./user.nix ]; }
  ];
}
