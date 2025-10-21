{ ... }:
{
  home.stateVersion = "25.05";

  home.sessionVariables = {
    NIXCONF_DIR = "$HOME/nixconf";
    PIP_REQUIRE_VIRTUALENV = "true";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
  ];
}
