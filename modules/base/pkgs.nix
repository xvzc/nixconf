{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # ┌───────────┐
    # │ Utilities │
    # └───────────┘
    jq
    zip
    wget
    curl
    unzip
    gnupg

    # ┌──────────────────────────────────┐
    # │ Productivity & System management │
    # └──────────────────────────────────┘
    gh
    fd
    vim
    git
    bat
    fzf
    tmux
    tree
    htop
    btop
    neovim
    ranger
    wezterm
    ripgrep
    openssh
    lazygit
    neofetch
    coreutils

    # ┌───────────────────┐
    # │ Basic environment │
    # └───────────────────┘
    go
    gcc
    cargo
    docker
    nodejs_20
    docker-compose
    (pkgs.python312.withPackages (
      ps:
        with ps; [
          pip
          pynvim
          # boj-cli
        ]
    ))

    # ┌───────────────────────────────┐
    # │ Language servers & Formatters │
    # └───────────────────────────────┘
    nixd
    shfmt
    stylua
    alejandra
    shellcheck
    clang-tools
    lua-language-server
    bash-language-server
  ];
}
