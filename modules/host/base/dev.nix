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
    "/share/terminfo"
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
