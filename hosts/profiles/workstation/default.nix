{
  pkgs,
  ctx,
  ...
}:
{
  imports = [
    ./overlays.nix
    ./${ctx.os}

    ../../shared/base.nix
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

    nerd-fonts.jetbrains-mono
    nerd-fonts.d2coding
  ];
}
