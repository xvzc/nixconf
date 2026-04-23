{ pkgs, ... }:
{
  home.packages = [ pkgs.kitty ];

  xdg.configFile = {
    "kitty/kitty.conf" = {
      source = ./dotfiles/kitty.conf;
    };

    "kitty/themes" = {
      source = ./dotfiles/themes;
      recursive = true;
    };
  };
}
