{
  lib,
  pkgs,
  config,
  wallpaper,
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
    lib.mkIf (wallpaper != null) # sh
      ''
        run /usr/bin/osascript <<EOF
          tell application "Finder"
            set desktop picture to POSIX file "${wallpaper}"
          end tell
        EOF
      '';
}
