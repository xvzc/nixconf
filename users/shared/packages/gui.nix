{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # GUI Applications
    alacritty
    discord
    google-chrome
    slack
    spotify
  ];
}
