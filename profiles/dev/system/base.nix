{
  ctx,
  lib,
  pkgs,
  ...
}@args:
let
in
{
  time.timeZone = "Asia/Seoul";
  environment.pathsToLink = [ "/share/zsh" ];

  environment.systemPackages =
    with pkgs;
    [
      btop
      coreutils
      curl
      docker_28
      docker-compose
      gcc
      gnupg
      htop
      neovim
      openssh
      unzip
      vim
      wget
      zip
    ];

  fonts.packages = with pkgs; [
    noto-fonts
    font-awesome
    noto-fonts-emoji
    material-design-icons
    nanum-square-neo

    (nerdfonts.override {
      fonts = [
        "JetBrainsMono"
        "D2Coding"
      ];
    })
  ];
}
