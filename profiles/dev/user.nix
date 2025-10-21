{ pkgs, ... }:
{
  home.sessionPath = [
    "$HOME/.local/share/JetBrains/Toolbox/scripts"
  ];

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
