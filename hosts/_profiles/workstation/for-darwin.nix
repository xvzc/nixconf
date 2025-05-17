{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../../../modules/host/darwin/programs/_1password-cli.nix
    ../../../modules/host/darwin/programs/_1password-gui.nix

    ../../../modules/host/darwin/services/yabai.nix

    ../../../modules/host/darwin/homebrew.nix
    ../../../modules/host/darwin/identity.nix
    ../../../modules/host/darwin/system.nix
  ];

  host.darwin.programs = {
    _1password.enable = true;
    _1password-gui.enable = true;
  };

  host.darwin.services = {
    yabai.enable = true;
  };
}
