{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
{
  # ┏━━━━┓
  # ┃ PI ┃
  # ┗━━━━┛
  imports = [
    "${inputs.home-manager-master}/modules/programs/pi-coding-agent.nix"
  ];

  home.sessionVariables = {
    PI_ASK_USER_DISPLAY_MODE = "inline";
  };

  home.file.".pi/agent" = {
    enable = lib.mkForce false;
    force = true;
  };

  home.packages = [
    pkgs.unstable.openspec
  ];

  xdg.configFile."pi-xvzc/agent" = {
    enable = lib.mkForce false;
  };

  xdg.configFile."pi-xvzc" = {
    source = inputs.pi-xvzc;
    recursive = true;
  };

  programs.pi-coding-agent = {
    enable = true;
    package = pkgs.unstable.pi-coding-agent;
    configDir = "${config.xdg.configHome}/pi-xvzc/agent";
    extraPackages = [ ];
  };
}
