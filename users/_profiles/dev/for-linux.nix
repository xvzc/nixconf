{ pkgs, ... }:
{
  imports = [
    ../../_common/wm/bspwm
  ];

  home.packages = with pkgs; [
    feh
  ];
}
