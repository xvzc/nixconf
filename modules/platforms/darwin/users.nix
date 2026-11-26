# The host's user (ctx.user). It already exists on macOS, but nix-darwin needs
# it declared to know its home: https://github.com/LnL7/nix-darwin/issues/423
{ ctx, pkgs, ... }:
{
  # The user that user-level settings (system.defaults, homebrew) apply to.
  system.primaryUser = ctx.user;

  users = {
    knownUsers = [ ctx.user ];
    users.${ctx.user} = {
      uid = 501; # macOS gives the first user 501
      home = "/Users/${ctx.user}";
      shell = pkgs.zsh;
    };
  };
}
