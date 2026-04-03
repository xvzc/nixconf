{
  ctx,
  ...
}:
assert ctx.isDarwin;
{
  imports = [
    ./system.nix
    { home-manager.users.${ctx.user} = ./user.nix; }
  ];
}
