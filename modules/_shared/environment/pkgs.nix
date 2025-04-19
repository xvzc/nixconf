{pkgs, ...}:
with pkgs; [
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
  eza
  bat
  fzf
  tmux
  tree
  htop
  btop
  neovim
  ranger
  ripgrep
  openssh
  lazygit
  starship
  neofetch
  coreutils

  # ┌───────────────────┐
  # │ Basic environment │
  # └───────────────────┘
  go
  gcc
  cargo
  docker_28
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
  clang_19
  alejandra
  shellcheck
  tree-sitter
  clang-tools
  lua-language-server
  bash-language-server
]
