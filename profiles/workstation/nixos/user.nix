{ pkgs, ... }:
{
  imports = [
    # ../../../shared/user/wm/bspwm
    ../../../shared/user/wm/hypr
    # ../../../shared/user/misc/kime.nix
  ];

  home.packages = with pkgs; [
    feh
    chromedriver
    wine
  ];
}
