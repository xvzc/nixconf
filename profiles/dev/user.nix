{ pkgs, inputs, ... }:
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
}
