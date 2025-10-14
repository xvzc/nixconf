{ pkgs, ... }:
{
  imports = [
    ../../../shared/features/wm/hypr
    ../../../shared/features/app/rofi
  ];

  home.packages = with pkgs; [
    feh
    electron-chromedriver_35
    wine
    clipse
  ];
}
