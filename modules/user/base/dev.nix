{ pkgs, ... }:
{
  imports = [
    ./_common.nix
  ];

  home.sessionPath = [
    "$HOME/.local/share/JetBrains/Toolbox/scripts"
  ];

  home.packages = with pkgs; [
    # Environment
    cargo
    clang_19
    go
    nodejs_22
    (pkgs.python312.withPackages (
      ps: with ps; [
        pip
        pynvim
      ]
    ))

    # Language Servers & Formatters
    bash-language-server
    clang-tools
    lua-language-server
    nixd
    nixfmt-rfc-style
    shellcheck
    shfmt
    stylua
    tree-sitter

    fastfetch
    jq
    ripgrep
    tree

    # GUI Applications
    discord
    google-chrome
    slack
    spotify
  ];
}
