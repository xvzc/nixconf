{ pkgs, ... }:
{
  imports = [
    # ../../../shared/user/wm/bspwm
    ../../../shared/features/wm/hypr
    # ../../../shared/user/misc/kime.nix
  ];

  home.packages = with pkgs; [
    feh
    electron-chromedriver_35
    wine
  ];
}
