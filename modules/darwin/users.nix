{
  config,
  lib,
  pkgs,
  ctx,
  ...
}:
let
  cfg = config.darwin.users;
in
with lib;
{
  options.darwin.users = {
    user = mkOption {
      type = types.str;
      default = ctx.user;
    };
  };

  config = {
    # The user should already exist, but we need to set
    # this up so Nix knows what our home directory is.
    # https://github.com/LnL7/nix-darwin/issues/423
    users = {
      knownUsers = [ "${cfg.user}" ];
      users.${cfg.user} = {
        uid = 501; # This is the default uid for darwin system
        home = "/Users/${cfg.user}";
        shell = pkgs.zsh;
      };
    };
  };
}
