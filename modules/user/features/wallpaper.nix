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

  config = lib.mkIf (cfg.source != null) {
    home.activation.setWallpaper =
      if pkgs.stdenv.isDarwin then
        # sh
        ''
          run /usr/bin/osascript <<EOF
            tell application "Finder"
              set desktop picture to POSIX file "${cfg.source}"
            end tell
          EOF
        ''
      else
        # sh
        ''

        '';
  };
}
