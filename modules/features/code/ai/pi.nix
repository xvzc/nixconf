{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
{
  imports = [
    "${inputs.home-manager-master}/modules/programs/pi-coding-agent.nix"
  ];
  # ┏━━━━┓
  # ┃ PI ┃
  # ┗━━━━┛

  home.file.".pi/agent/settings.json" = {
    enable = lib.mkForce false;
    force = true;
  };

  programs.pi-coding-agent = {
    enable = true;
    package = pkgs.unstable.pi-coding-agent;
    configDir = "${config.xdg.configHome}/pi/agent";
    settings = {
      # model = "sonnet";
      defaultShell = "zsh";
      includeCoAuthoredBy = false;
      tuiMode = "fullscreen";
    };
  };
}
