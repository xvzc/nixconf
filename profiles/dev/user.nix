{
  pkgs,
  inputs,
  lib,
  ...
}:
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
    unstable.slack
    # spoofdpi
    spotify
    tree
    vscode
    unstable.antigravity

    unstable.bash-language-server
    shellcheck
    shfmt
    tree-sitter
  ];
}
