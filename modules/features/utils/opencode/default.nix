{ ctx, ... }:
{
  imports = [
    ./overlays.nix
    { home-manager.users.${ctx.user} = ./user.nix; }
  ];
}
