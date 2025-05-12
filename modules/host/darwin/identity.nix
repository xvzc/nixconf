{
  config,
  pkgs,
  lib,
  ctx,
  ...
}:
let
  cfg = config.host.darwin.identity;
in
with lib;
{
  options.host.darwin.identity = {
    host = mkOption {
      type = types.str;
      default = ctx.host;
    };

    user = mkOption {
      type = types.str;
      default = ctx.user;
    };
  };

  config = {
    # The user should already exist, but we need to set
    # this up so Nix knows what our home directory is.
    # https://github.com/LnL7/nix-darwin/issues/423
    # programs.fish.enable = true;
    users = {
      knownUsers = [ "${cfg.user}" ];
      users.${cfg.user} = {
        uid = 501; # This is the default uid for darwin system
        home = "/Users/${cfg.user}";
        shell = pkgs.zsh;
      };
    };

    networking = {
      hostName = cfg.host;
      computerName = cfg.host;
      localHostName = cfg.host;
    };
  };
}
