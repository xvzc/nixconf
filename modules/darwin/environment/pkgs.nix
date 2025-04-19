{pkgs, ...}:
pkgs.callPackage ../../_shared/environment/pkgs.nix {}
++ (with pkgs; [
  pam-reattach
])
