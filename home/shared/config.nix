{...}: let
in {
  home.stateVersion = "24.11";
  home.enableNixpkgsReleaseCheck = false;
  manual.manpages.enable = true;
}
