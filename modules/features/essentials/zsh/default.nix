{
  lib,
  ctx,
  ...
}:
{
  imports = [
    ./system.nix
    { home-manager.users.${ctx.user} = ./user.nix; }
  ];
}
