{
  lib,
  ctx,
  config,
  ...
}:
{
  options.wm.hyprland = {
    enable = lib.mkEnableOption "Whether to enable hyprland";
    default = false;
  };

  imports = [
    ./host.nix

    ./hypridle
    ./hyprland
    ./hyprlock
    ./hyprpaper
    ./waybar
  ];

  config = lib.mkIf config.wm.hyprland.enable {
    home-manager.users.${ctx.user} = lib.mkMerge [
      ./user.nix
    ];
  };

}
