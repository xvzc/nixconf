{
  pkgs,
  ...
}:
{
  imports = [
    ./system.nix
    # { home-manager.users.${ctx.user} = ./user.nix; }
  ];

  assertions = [
    {
      assertion = pkgs.stdenv.isLinux;
      message = "The module '${./default.nix}' can only be used on Linux systems.";
    }
  ];
}
