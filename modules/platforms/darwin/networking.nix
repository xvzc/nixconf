# Every name macOS has for the machine is the host's.
{ ctx, ... }:
{
  networking = {
    hostName = ctx.host;
    computerName = ctx.host;
    localHostName = ctx.host;
    domain = ctx.host;
  };
}
