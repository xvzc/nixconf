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

  environment.shells = [
    pkgs.zsh
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

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
    openssh
    unzip
    vim
    wget
    zip
  ];
}
