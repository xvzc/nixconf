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
    jq
    ripgrep
    tree

    clang-tools

    # jetbrains.idea-community-bin
    slack
    spotify
    cava
    fastfetch
  ];
}
