{ pkgs, ... }:
{
  imports = [
    ../../../shared/user/wm/bspwm
    # ../../_common/wm/hypr
  ];

  home.packages = with pkgs; [
    feh
  ];
}
