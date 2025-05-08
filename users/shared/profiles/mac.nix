{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.mac;
in
with lib;
{
  imports = [
    ./base.nix

    ../features/1password
    ../features/bat
    ../features/eza
    ../features/fd
    # ../features/fish
    ../features/fzf
    ../features/git
    ../features/jetbrains
    ../features/neovim
    ../features/kitty
    ../features/ssh
    ../features/tmux
    ../features/wezterm
    ../features/yabai
    ../features/zsh

    ../packages/cli.nix
    ../packages/code.nix
    ../packages/gui.nix
  ];

  options.mac = {
    wallpaper.source = mkOption {
      type = types.path;
      default = null;
    };
  };

  config = {
    targets.darwin.keybindings = {
      "₩" = [ "insertText:" ] ++ [ "`" ];
    };

    home.packages = with pkgs; [
      pngpaste
    ];

    home.sessionPath = [
      "/opt/homebrew/bin"
    ];

    home.activation.setWallpaper =
      mkIf (cfg.wallpaper.source != null) # sh
        ''
          run /usr/bin/osascript \
            -e 'tell application "Finder"' \
            -e '  set desktop picture to POSIX file "${cfg.wallpaper.source}"' \
            -e 'end tell';
        '';
  };
}
