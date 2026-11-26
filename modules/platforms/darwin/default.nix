# Every Darwin host imports this (lib/mk-system.nix).
{ lib, ... }:
{
  imports = [
    ./networking.nix
    ./system-preferences.nix
    ./users.nix
  ];

  options.platforms.darwin.systemPreferences.enable =
    lib.mkEnableOption "the macOS system preferences in ./system-preferences.nix"
    // {
      default = true;
    };
}
