{
  lib,
  ctx,
  pkgs,
  ...
}:
{
  options.wm.hyprland = {
    enable = lib.mkEnableOption "Whether to enable 'hyprland'";
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
  ];

  assertions = [
    {
      assertion = pkgs.stdenv.isLinux;
      message = "The module '${./default.nix}' can only be used on Linux systems.";
    }
  ];
}
