{pkgs, ...}: let
  environmentFiles = import ./files.nix {inherit pkgs;};
in {
  systemPackages = pkgs.callPackage ./pkgs.nix {};
  etc = environmentFiles.etc;
}
