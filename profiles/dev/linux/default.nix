{
  lib,
  ctx,
  ...
}:
{
  imports = [
    ./overlays.nix

    ../../../modules/features/linux/chrony
    ../../../modules/features/linux/hypr
    ../../../modules/features/linux/kime
    ../../../modules/features/linux/rofi
  ];

  home-manager.users.${ctx.user} = lib.mkMerge [
    ./user.nix
  ];
}
