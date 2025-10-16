{
  lib,
  config,
  ...
}:
lib.mkIf config.wm.hyprland.enable {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };
}
