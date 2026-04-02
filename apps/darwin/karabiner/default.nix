{
  lib,
  ctx,
  pkgs,
  ...
}:
{
  imports = [
    ./overlays.nix
    ./system.nix
    { home-manager.users.${ctx.user} = ./user.nix; }
  ];

  assertions = [
    {
      assertion = pkgs.stdenv.isDarwin;
      message = "The module '${./default.nix}' can only be used on Darwin systems.";
    }
  ];
}
