{ ctx, ... }:
{
  home.stateVersion = "24.11";

  home.sessionVariables = {
    NIX_HOST = ctx.host;
    NIXCONF_DIR = "$HOME/nixconf";
    PIP_REQUIRE_VIRTUALENV = "true";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.local/share/JetBrains/Toolbox/scripts"
  ];
}
