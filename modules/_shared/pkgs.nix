{ pkgs, ... }:

with pkgs;
[
  # _1password-cli # linux only
  # _1password-gui # linux only
  google-chrome
  discord
  slack

  # General packages for development and system management
  starship
  neovim
  git
  unzip
  tree
  htop
  tmux
  ripgrep
  jq
  fzf
  fd
  bat
  btop
  coreutils
  gcc
  neofetch
  openssh
  wget
  curl
  lazygit
  ranger
  zip

  docker
  docker-compose

  go
  terraform
  luarocks

  # Source code management, Git, GitHub tools
  gh

  # Python packages
  python3
]
