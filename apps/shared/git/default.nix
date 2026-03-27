{
  lib,
  ctx,
  pkgs,
  ...
}:
{
  imports = [
    { home-manager.users.${ctx.user} = ./user.nix; }
  ];
}
