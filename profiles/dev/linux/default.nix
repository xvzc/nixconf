{
  lib,
  pkgs,
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

  environment.systemPackages = with pkgs; [
    lm_sensors
    pamixer
    dig
  ];

  virtualisation.docker.enable = true;


  home-manager.users.${ctx.user} =
    { ... }:
    {
      home.packages = with pkgs; [
        feh
        electron-chromedriver_35
        wine
        clipse
      ];
    };
}
