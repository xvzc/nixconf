{
  lib,
  pkgs,
  ctx,
  ...
}:
{
  home-manager.users.${ctx.user} =
    { config, ... }:
    {
      services.hyprpaper = {
        enable = true;
        settings = {
          ipc = "on";
          splash = false;
          splash_offset = 2.0;

          preload = [
            config.wallpaper.source

          ];
          # let
          #   wallpapersDir = "${inputs.assets}/wallpapers";
          #   fileNames = builtins.attrNames (builtins.readDir wallpapersDir);
          # in
          # builtins.map (name: "${wallpapersDir}/${name}") fileNames;
          # [
          #   "${inputs.assets}/wallpapers/anime-girl-nun.jpg"
          #   "${inputs.assets}/wallpapers/anime-cat-clouds.jpg"
          # ];
          wallpaper = lib.mkIf (config.wallpaper != null) [
            ", ${config.wallpaper.source}"
          ];
        };
      };
    };
}
