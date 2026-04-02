{ pkgs, ... }:
{
  imports = [
    ./system.nix
  ];

  assertions = [
    {
      assertion = pkgs.stdenv.isLinux;
      message = "The module '${./default.nix}' can only be used on Linux systems.";
    }
  ];
}
