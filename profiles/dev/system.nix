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
    font-awesome
    noto-fonts-emoji
    material-design-icons
    nanum-square-neo
    d2coding

    nerd-fonts.jetbrains-mono
    nerd-fonts.d2coding
  ];

}
