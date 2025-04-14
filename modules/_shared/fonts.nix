{ pkgs, ... }:
with pkgs;
[
  material-design-icons
  font-awesome

  font-awesome
  noto-fonts
  noto-fonts-emoji
  (nerdfonts.override {
    fonts = [
      "JetBrainsMono"
    ];
  })

  # (nerdfonts.override {
  #   fonts = [
  #     "jetbrains-mono"
  #   ];
  # })
]
