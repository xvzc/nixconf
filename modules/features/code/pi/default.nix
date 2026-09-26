{ ctx, lib, ... }:
{
  imports = [
    {
      home-manager.users.${ctx.user} = lib.mkMerge [
        ./user.nix
      ];
    }
  ];
}
