{ ctx, lib, ... }:
{
  home-manager.users.${ctx.user} = lib.mkMerge [
    ./user.nix
  ];
}
