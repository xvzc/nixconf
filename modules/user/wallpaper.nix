{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.wallpaper;
in
with lib;
{
  options.wallpaper = {
    source = mkOption {
      type = types.nullOr types.path;
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
      home.activation.setWallpaper =
        # sh
        ''
          run ${pkgs.feh}/bin/feh --bg-fill ${cfg.source}
        '';
    })
  ]);
}
