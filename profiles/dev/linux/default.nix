{
  lib,
  ctx,
  ...
}:
{
  imports = [
    ./system.nix

    ../../../apps/linux/chrony
    ../../../apps/linux/hypr
    ../../../apps/linux/kime
    ../../../apps/linux/rofi
  ];

  home-manager.users.${ctx.user} = lib.mkMerge [
    ./user.nix
  ];
}
