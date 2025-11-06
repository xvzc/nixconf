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
    ../../../modules/features/darwin/karabiner
    # ../../../modules/features/darwin/aerospace
    # ../../../modules/features/darwin/jankyborders
  ];

  home-manager.users.${ctx.user} = lib.mkMerge [
    ./user.nix
  ];
}
