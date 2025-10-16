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
      source = ./_files/wezterm.lua;
    };

    "wezterm/colors" = {
      source = ./_files/colors;
      recursive = true;
    };
  };
}
