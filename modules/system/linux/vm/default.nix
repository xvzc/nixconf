{ ctx, ... }:
assert ctx.isLinux;
{
  imports = [
    ./host.nix
    ./guests.nix
  ];
}
