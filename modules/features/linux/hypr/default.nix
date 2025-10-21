{
  lib,
  ctx,
  ...
}:
{
  options.wm.hyprland = {
    enable = lib.mkEnableOption "Whether to enable 'hyprland'";
  };

  imports = [
    ./system.nix
    { home-manager.users.${ctx.user} = ./user.nix; }

    ./hypridle
    ./hyprland
    ./hyprlock
    ./hyprpaper
    ./waybar
  ];
}
