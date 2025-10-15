{
  lib,
  pkgs,
  ctx,
  ...
}:
{
  home-manager.users.${ctx.user} =
    { ... }:
    {
      home.packages = [ pkgs.kitty ];

      xdg.configFile = {
        "kitty/kitty.conf" = {
          source = ./kitty.conf;
        };

        "kitty/themes" = {
          source = ./themes;
          recursive = true;
        };
      };
    };
}
