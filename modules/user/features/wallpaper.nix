{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.user.features.wallpaper;
in
with lib;
{
  options.user.features.wallpaper = {
    source = mkOption {
      type = types.path;
      default = null;
    };
  };

  config = lib.mkIf (cfg.source != null) (lib.mkMerge [
    (lib.mkIf pkgs.stdenv.isDarwin {
      home.activation.setWallpaper =
        # sh
        ''
          run /usr/bin/osascript <<EOF
            tell application "Finder"
              set desktop picture to POSIX file "${cfg.source}"
            end tell
          EOF
        '';
    })

    (lib.mkIf pkgs.stdenv.isLinux {
      services.hyprpaper = {
        enable = true;
        settings = {
          ipc = "on";
          splash = false;
          splash_offset = 2.0;
          preload = [ cfg.source ];
          wallpaper = [ ", ${cfg.source}" ];
        };
      };

      home.activation.setWallpaper =
        # sh
        ''
          ${pkgs.hyprland}/bin/hyprctl hyprpaper unload all || true
          ${pkgs.hyprland}/bin/hyprctl hyprpaper preload "${cfg.source}" || true
          ${pkgs.hyprland}/bin/hyprctl hyprpaper wallpaper ", ${cfg.source}" || true
        '';
    })
  ]);
}
