{
  lib,
  config,
  ...
}:
lib.mkIf config.wm.hyprland.enable {
  # environment.pathsToLink = [
  #   "/share/applications"
  #   "/share/xdg-desktop-portal"
  # ];
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = false;
  };
}
