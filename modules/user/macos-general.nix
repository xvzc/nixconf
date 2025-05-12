{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.user.macos-general;
in
with lib;
{
  imports = [
    ./base.nix

    ./features/git
    ./features/jetbrains
    ./features/kitty
    ./features/tmux
    ./features/wezterm
    ./features/yabai
    ./features/zsh

    ./features/1password.nix
    ./features/bat.nix
    ./features/direnv.nix
    ./features/eza.nix
    ./features/fd.nix
    ./features/fzf.nix
    ./features/neovim.nix
    ./features/ssh.nix

    ./packages/cli.nix
    ./packages/dev.nix
    ./packages/gui.nix
  ];

  options.user.macos-general = {
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
          run /usr/bin/osascript <<EOF
            tell application "Finder"
              set desktop picture to POSIX file "${cfg.wallpaper.source}"
            end tell
          EOF
        '';
  };
}
