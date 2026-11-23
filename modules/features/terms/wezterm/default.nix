{
  pkgs,
  lib,
  ctx,
  ...
}:
{
  # ┌────────┐
  # │ COMMON │
  # └────────┘
  nixpkgs.overlays = lib.mkBefore [
    (final: prev: {
      wezterm =
        if pkgs.stdenv.isDarwin then
          final.mv.tip.wezterm
        else
          final.mv.tip.wezterm.overrideAttrs (old: {
            patches = (old.patches or [ ]) ++ [
              # Wayland text-input-v3: Hyprland forwards a cleared preedit as "" (not
              # null), which wezterm kept as an active composition, so the cursor stayed
              # a block and ignored DECSCUSR (e.g. zsh vi-mode beam) until the next IME
              # event. Not fixed upstream as of 2026-11-24.
              ./patches/01-wayland-empty-preedit-ends-composition.patch
            ];
          });
    })
  ];

  home-manager.users.${ctx.user} =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      home.packages = [ pkgs.wezterm ];

      xdg.configFile = {
        "wezterm/wezterm.lua" = {
          source = ./dotfiles/wezterm.lua;
        };

        "wezterm/colors" = {
          source = ./dotfiles/colors;
          recursive = true;
        };

        # Opens a new window in the running WezTerm, or starts it (macOS app
        # path). Bound by window managers, e.g. skhdrc alt - return.
        "wezterm/scripts/open-wezterm" = lib.mkIf ctx.isDarwin {
          source = ./dotfiles/scripts/open-wezterm;
        };
      };
    };
}
