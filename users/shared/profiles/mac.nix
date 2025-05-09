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
    ../features/git
    ../features/jetbrains
    ../features/kitty
    ../features/tmux
    ../features/wezterm
    ../features/yabai
    ../features/zsh

    ../features/bat.nix
    ../features/eza.nix
    ../features/fd.nix
    ../features/fzf.nix
    ../features/neovim.nix
    ../features/ssh.nix

    ../packages/cli.nix
    ../packages/dev.nix
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
