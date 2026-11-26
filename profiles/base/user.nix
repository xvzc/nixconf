{ pkgs, ... }:
{
  home.sessionVariables = {
    NIXOS_SYSTEM = pkgs.stdenv.hostPlatform.system;
    NIXOS_CONFIG = "$HOME/nixconf";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
  ];
}
