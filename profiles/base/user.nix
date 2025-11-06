{ pkgs, ... }:
{
  home.stateVersion = "25.05";

  home.sessionVariables = {
    NIXOS_SYSTEM = pkgs.system;
    NIXOS_CONFIG = "$HOME/nixconf";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
  ];
}
