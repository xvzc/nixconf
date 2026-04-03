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
      kdePackages = final.unstable.kdePackages;
      wine = final.unstable.wine;
      rofi = final.unstable.rofi;
      waybar = final.unstable.waybar;
      hyprland = final.unstable.hyprland;

      rofi-power-menu = final.unstable.rofi-power-menu;
    })
  ];
}
