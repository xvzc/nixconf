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
    cava
    fastfetch
    gemini-cli
    jq
    ripgrep
    slack
    spotify
    tree
    vscode
  ];
}
