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
    mv.tip.openssh
    openssl
    unzip
    vim
    wget
    zip

    mv.tip.nodejs
    (pkgs.python313.withPackages (
      ppkgs: with ppkgs; [
        pip
      ]
    ))
  ];
}
