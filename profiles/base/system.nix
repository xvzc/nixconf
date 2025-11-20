{ pkgs, ... }:
{
  time.timeZone = "Asia/Seoul";

  environment.systemPackages = with pkgs; [
    btop
    coreutils
    cmake
    curl
    gcc
    gnumake
    gnupg
    home-manager
    htop
    unstable.openssh
    unzip
    vim
    wget
    zip

    bash-language-server
    nixd
    alejandra
    nodejs
    shellcheck
    shfmt
    tree-sitter
    (pkgs.python312.withPackages (
      ppkgs: with ppkgs; [
        pip
        python-lsp-server
        black
        flake8
      ]
    ))
  ];
}
