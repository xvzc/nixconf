{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  options.wallpaper = with lib; {
    source = mkOption {
      type = types.nullOr types.path;
      default = null;
    };
  };

  config = {
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
      gemini-cli
      google-chrome
      jq
      ripgrep
      slack
      # spoofdpi
      spotify
      tree
      vscode
      antigravity
    ];
  };
}
