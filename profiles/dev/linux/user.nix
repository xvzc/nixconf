{ pkgs, ... }:
{
  home.packages = with pkgs; [
    feh
    # electron-chromedriver_35
    desktop-file-utils
    wine
    clipse
  ];
}
