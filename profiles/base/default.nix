{
  ctx,
  lib,
  ...
}:
{
  imports = [
    ./system.nix
    { home-manager.users.${ctx.user} = lib.mkMerge [ ./user.nix ]; }
  ];
}
