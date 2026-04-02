{
  lib,
  pkgs,
  ctx,
  ...
}:
{
  imports = [
    ./system.nix

    ../../../apps/darwin/yabai
    ../../../apps/darwin/karabiner
    # ../../../apps/darwin/aerospace
    # ../../../apps/darwin/jankyborders
  ];

  home-manager.users.${ctx.user} = lib.mkMerge [
    ./user.nix
  ];
}
