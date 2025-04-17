{ pkgs, ... }:
{
  system = with pkgs; [
    neovim
    vim

    docker
    docker-compose

    gnupg
    git
    openssh
    curl
    jq
    wget
    zip
    fd
    ripgrep
    fzf
    unzip
    bat
    tree

    # Language support
    nixd
    nixfmt-rfc-style
    alejandra

    nodejs_20
    (pkgs.python312.withPackages (
      ps: with ps; [
        pip
        pynvim
        # boj-cli
      ]
    ))
  ];

  home = with pkgs; [
    # _1password-cli # linux only
    # _1password-gui # linux only
    # google-chrome
    # discord
    # slack
    wezterm

    # General packages for development and system management
    htop
    tmux
    btop
    coreutils
    neofetch
    lazygit
    ranger
    gh

    go
    gcc
    terraform
    luarocks
    cargo

  ];
}
