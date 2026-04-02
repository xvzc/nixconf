{
  lib,
  ctx,
  ...
}:
{
  imports = [
    ./overlays.nix
    ./system.nix
    { home-manager.users.${ctx.user} = ./user.nix; }
  ];
}
