{
  lib,
  pkgs,
  config,
  ...
}:
{
  targets.darwin.keybindings = {
    "₩" = [ "insertText:" ] ++ [ "`" ];
  };

  home.packages = with pkgs; [
    pngpaste
    im-select
  ];

  home.activation.setWallpaper =
    lib.mkIf (config.wallpaper.source != null) # sh

      ''
        run /usr/bin/osascript <<EOF
          tell application "Finder"
            set desktop picture to POSIX file "${config.wallpaper.source}"
          end tell
        EOF
      '';
}
