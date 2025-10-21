{
  lib,
  ctx,
  ...
}:
{
  imports = [
    { home-manager.users.${ctx.user} = ./user.nix; }
  ];
}
