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

    # nixd
    # alejandra
    unstable.nodejs
    (pkgs.python312.withPackages (
      ppkgs: with ppkgs; [
        pip
      ]
    ))
  ];
}
