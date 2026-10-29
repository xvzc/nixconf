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
      wezterm = final.mv.tip.wezterm;
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
      };
    };
}
