# Every Linux host imports this (lib/mk-system.nix).
{
  imports = [
    ./audio.nix
    ./hardware.nix
    ./networking.nix
    ./users.nix
  ];
}
