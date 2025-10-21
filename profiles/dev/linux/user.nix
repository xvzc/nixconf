{ pkgs, ... }:
{
  home.packages = with pkgs; [
    feh
    electron-chromedriver_35
    wine
    clipse
  ];
}
