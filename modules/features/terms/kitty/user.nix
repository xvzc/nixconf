{ pkgs, ... }:
{
  home.packages = [ pkgs.kitty ];

  xdg.configFile = {
    "kitty/kitty.conf" = {
      source = ./_files/kitty.conf;
    };

    "kitty/themes" = {
      source = ./_files/themes;
      recursive = true;
    };
  };
}
