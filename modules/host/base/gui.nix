{
  pkgs,
  ...
}:
let
in
{
  imports = [
    ./_common.nix
  ];

  environment.pathsToLink = [
    "/share/terminfo"
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
