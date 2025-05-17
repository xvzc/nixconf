{
  lib,
  pkgs,
  ...
}:
let
  user = "kazusa";
  host = "macbook-air-m2";
in
{
  imports = [
    ../_profiles/workstation
  ];

  # The user should already exist, but we need to set
  # this up so Nix knows what our home directory is.
  # https://github.com/LnL7/nix-darwin/issues/423
  # programs.fish.enable = true;
  users = {
    knownUsers = [ user ];
    users.${user} = {
      uid = 501; # This is the default uid for darwin system
      home = "/Users/${user}";
      shell = pkgs.zsh;
    };
  };

  networking = {
    hostName = host;
    computerName = host;
    localHostName = host;
  };

  nix-homebrew.user = user;

  system.defaults.loginwindow.autoLoginUser = user;
  system.defaults.dock = {
    persistent-others = lib.mkForce [ ];
    persistent-apps = [
      "${pkgs.google-chrome}/Applications/Google Chrome.app"
      "${pkgs.spotify}/Applications/Spotify.app"
      "${pkgs.wezterm}/Applications/WezTerm.app"
    ];
  };
}
