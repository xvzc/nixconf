{
  lib,
  pkgs,
  ctx,
  ...
}:
{
  # Disable pre-defined nix-darwin modules to override.
  disabledModules = [
    "services/yabai"
  ];

  imports = [
    ./profiles/workstation

    ../modules/host/darwin/yabai.nix
  ];

  # The user should already exist, but we need to set
  # this up so Nix knows what our home directory is.
  # https://github.com/LnL7/nix-darwin/issues/423
  users = {
    knownUsers = [ ctx.user ];
    users.${ctx.user} = {
      uid = 501; # This is the default uid for darwin system
      home = "/Users/${ctx.user}";
      shell = pkgs.zsh;
    };
  };

  networking = {
    hostName = ctx.host;
    computerName = ctx.host;
    localHostName = ctx.host;
    domain = ctx.host;
  };

  system.defaults.dock = {
    persistent-others = lib.mkForce [ ];
    persistent-apps = [
      # "${pkgs.fie}/Applications/Google Chrome.app"
      "${pkgs.firefox}/Applications/Firefox.app"
      "${pkgs.spotify}/Applications/Spotify.app"
      "${pkgs.kitty}/Applications/kitty.app"
    ];
  };

  services.yabai.enable = true;

  system.stateVersion = 6;
}
