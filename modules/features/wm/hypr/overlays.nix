{
  lib,
  ctx,
  inputs,
  ...
}:
{
  # ┌───────┐
  # │ LINUX │
  # └───────┘
  nixpkgs.overlays = [
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
