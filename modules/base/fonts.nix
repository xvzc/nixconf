{pkgs, ...}: let
in {
  fonts.packages = with pkgs; [
    noto-fonts
    font-awesome
    noto-fonts-emoji
    material-design-icons

    (nerdfonts.override {
      fonts = [
        "JetBrainsMono"
        "D2Coding"
      ];
    })
  ];
}
