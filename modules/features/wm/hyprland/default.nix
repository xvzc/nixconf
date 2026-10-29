{
  lib,
  ctx,
  ...
}:
assert ctx.isLinux;
{
  options.features.wm.hyprland.enable = lib.mkEnableOption "Whether to enable 'hyprland'";

  imports = [
    ./hypridle.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./waybar.nix
    ./rofi.nix
  ];

  # ┌───────┐
  # │ LINUX │
  # └───────┘
  config.nixpkgs.overlays = [
    (final: prev: {
      kdePackages = final.mv.tip.kdePackages;
      # wine = final.mv.tip.wine;
      rofi = final.mv.tip.rofi;
      waybar = final.mv.tip.waybar;
      hyprland = final.mv.tip.hyprland;

      rofi-power-menu = final.mv.tip.rofi-power-menu;
    })
  ];
}
