{ pkgs, ... }:
{
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
  ];
}
