{
  lib,
  ctx,
  config,
  ...
}:
{
  imports =
    lib.optionals (builtins.pathExists ./system.nix) [
      ./system.nix
    ]
    ++ lib.optionals (builtins.pathExists ./user.nix) [
      { home-manager.users.${ctx.user} = ./user.nix; }
    ];
}
