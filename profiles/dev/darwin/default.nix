{
  lib,
  pkgs,
  ctx,
  ...
}:
{
  imports = [
    ./overlays.nix
    ./system.nix

    ../../../modules/features/darwin/yabai
  ];

  home-manager.users.${ctx.user} = lib.mkMerge [
    ./user.nix
  ];
}
