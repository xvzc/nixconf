# The host's user (ctx.user). Groups come from the modules that need them, and
# ssh keys from the host.
{ ctx, pkgs, ... }:
{
  users.users.${ctx.user} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
  };
}
