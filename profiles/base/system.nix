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
    jq
    unstable.openssh
    openssl
    unzip
    vim
    wget
    zip

    unstable.nodejs
    (pkgs.python312.withPackages (
      ppkgs: with ppkgs; [
        pip
      ]
    ))
  ];
}
