{
  lib,
  pkgs,
  ctx,
  ...
}:
{
  environment.pathsToLink = [
    "/share/terminfo"
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    font-awesome
    material-design-icons
    nanum-square-neo
    d2coding

    nerd-fonts.jetbrains-mono
    nerd-fonts.d2coding
  ];

}
