{
  lib,
  ctx,
  inputs,
  ...
}:
{
  nixpkgs.overlays =
    # ┌────────┐
    # │ COMMON │
    # └────────┘
    lib.lists.flatten [
      (final: prev: {
        nanum-square-neo = final.callPackage ../../pkgs/nanum-square-neo.nix { };

        gh = final.unstable.gh;
        bash-language-server = final.unstable.bash-language-server;
        slack = final.unstable.slack;
        tmuxPlugins.catppuccin = final.unstable.tmuxPlugins.catppuccin;
        wezterm = final.unstable.wezterm;
      })
    ]
    # ┌────────┐
    # │ DARWIN │
    # └────────┘
    ++ lib.optionals ctx.isDarwin [
      (final: prev: {
        im-select = final.callPackage ../../pkgs/im-select.nix { };
        skhd = final.unstable.skhd;
        yabai = final.unstable.yabai;
      })
    ]
    # ┌───────┐
    # │ LINUX │
    # └───────┘
    ++ lib.optionals ctx.isLinux [
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
        _1password-cli = final.unstable._1password-cli;

        # pavucontrol = final.unstable.pavucontrol.overrideAttrs (old: {
        #
        #   postInstall = ''
        #     ${old.postInstall or ""}
        #     mkdir -p $out/share/icons
        #     cp -r ${inputs.assets}/icons/pavucontrol/* $out/share/icons
        #   '';
        # });
      })
    ];
}
