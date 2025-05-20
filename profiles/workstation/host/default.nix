{
  pkgs,
  ctx,
  ...
}:
{
  imports = [
    ../../_base/host.nix
    ./for-${ctx.os}.nix
  ];

  environment.pathsToLink = [
    "/share/terminfo"
  ];

  programs = {
    _1password.enable = true;
    _1password-gui.enable = true;
  };

  fonts.packages = with pkgs; [
    noto-fonts
    font-awesome
    noto-fonts-emoji
    material-design-icons
    nanum-square-neo
    d2coding

    (nerdfonts.override {
      fonts = [
        "JetBrainsMono"
        "D2Coding"
      ];
    })
  ];
}
