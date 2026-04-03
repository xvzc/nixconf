{
  lib,
  ctx,
  pkgs,
  ...
}:
assert ctx.isLinux;
{
  options.features.wm.hypr = {
    enable = lib.mkEnableOption "Whether to enable 'hyprland'";
    withRofi = lib.mkEnableOption "Whether to enable 'hyprland'";
  };

  imports = [
    ./overlays.nix
    ./system.nix
    { home-manager.users.${ctx.user} = ./user.nix; }

    ./hypridle
    ./hyprland
    ./hyprlock
    ./hyprpaper
    ./waybar
    ./rofi
  ];
}
