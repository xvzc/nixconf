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

      discord = final.unstable.discord.overrideAttrs (old: {
        postInstall = ''
          ${old.postInstall or ""}
          wrapProgram $out/bin/Discord \
            --add-flags "--ozone-platform=x11"

          ${old.postInstall or ""}
          wrapProgram $out/bin/discord \
            --add-flags "--ozone-platform=x11"
        '';
      });

      _1password-gui = final.unstable._1password-gui.overrideAttrs (old: {
        postInstall = ''
          ${old.postInstall or ""}
          wrapProgram $out/share/1password/1password \
            --add-flags "--ozone-platform=x11"
        '';
      });

      rofi-power-menu = final.unstable.rofi-power-menu.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          ../../../patches/rofi-power-menu.patch
        ];
      });
    })
  ];
}
