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
}
