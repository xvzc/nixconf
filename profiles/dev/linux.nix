{ ... }:
{
  # Unlike `nix-darwin`, `nixos` requires `system.stateVersion` to be a string.
  # So we set this option separately based on the current platform.
  system.stateVersion = "24.11";
}
