{
  pkgs,
  inputs,
  lib,
  ctx,
  wallpaper,
  ...
}:
lib.mkMerge [
  # ┌────────┐
  # │ COMMON │
  # └────────┘
  {
    home.sessionPath = [
      "$HOME/.local/share/JetBrains/Toolbox/scripts"
    ];

    xdg.configFile."assets" = {
      source = inputs.assets;
      recursive = true;
    };

    home.packages = with pkgs; [
      # cava
      fastfetch
      unstable.gemini-cli
      google-chrome
      jq
      ripgrep
      unstable.slack
      # spoofdpi
      spotify
      tree
      vscode
      unstable.antigravity

      unstable.lazygit
      unstable.bash-language-server
      shellcheck
      shfmt
      tree-sitter
    ];
  }
  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  # ┌────────┐
  # │ DARWIN │
  # └────────┘
  (lib.optionalAttrs ctx.isDarwin {
    targets.darwin.keybindings = {
      "₩" = [ "insertText:" ] ++ [ "`" ];
    };

    home.packages = with pkgs; [
      pngpaste
      # im-select
      unstable.macism
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
  })
  # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  # ┌───────┐
  # │ LINUX │
  # └───────┘
  (lib.optionalAttrs ctx.isLinux {
    home.packages = with pkgs; [
      feh
      # electron-chromedriver_35
      desktop-file-utils
      wine
      clipse
    ];
  })
]
