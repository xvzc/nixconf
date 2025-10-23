{ pkgs, ... }:
{
  home.stateVersion = "25.05";

  home.sessionVariables = {
    NIXPKGS_SYSTEM = pkgs.system;
    NIXCONF_DIR = "$HOME/nixconf";
    PIP_REQUIRE_VIRTUALENV = "true";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
  ];
}
