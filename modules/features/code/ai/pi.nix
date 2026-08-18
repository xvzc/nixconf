{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    "${inputs.home-manager-master}/modules/programs/pi-coding-agent.nix"
  ];
  # ┏━━━━┓
  # ┃ PI ┃
  # ┗━━━━┛

  programs.pi-coding-agent = {
    enable = true;
    # settings = {
    #   model = "sonnet";
    #   defaultShell = "bash";
    #   includeCoAuthoredBy = false;
    # };
  };
}
