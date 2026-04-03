{
  lib,
  config,
  ...
}:
lib.mkIf (config.features.wm.hypr.enable) {
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
