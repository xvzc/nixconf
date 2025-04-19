{pkgs, ...}:
pkgs.callPackage ../../_shared/home/pkgs.nix {}
++ (with pkgs; [
  aerospace
  pngpaste
])
