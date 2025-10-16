{
  lib,
  ctx,
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
