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
      discord = final.unstable.discord;

      _1password-gui = final.unstable._1password-gui.overrideAttrs (old: {
        postInstall = ''
          ${old.postInstall or ""}
          wrapProgram $out/share/1password/1password \
            --add-flags "--ozone-platform-hint=x11"
        '';
      });
    })
  ];
}
