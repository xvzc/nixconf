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
      source = ./wezterm.lua;
    };

    "wezterm/colors" = {
      source = ./colors;
      recursive = true;
    };
  };
}
