{
  ...
}:
let
in
{
  imports = [
    ./base/gui.nix

    ./darwin/programs/_1password-cli.nix
    ./darwin/programs/_1password-gui.nix
    ./darwin/services/yabai.nix

    ./darwin/homebrew.nix
    ./darwin/identity.nix
    ./darwin/system.nix
  ];

  host.darwin.programs = {
    _1password.enable = true;
    _1password-gui.enable = true;
  };

  host.darwin.services = {
    yabai.enable = true;
  };
}
