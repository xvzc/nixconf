{
  pkgs,
  ...
}:
let
in
{
  time.timeZone = "Asia/Seoul";
  environment.pathsToLink = [
    "/share/zsh"
  ];

  environment.systemPackages = with pkgs; [
    btop
    coreutils
    curl
    gcc
    gnupg
    home-manager
    htop
    openssh
    unzip
    vim
    wget
    zip
  ];
}
