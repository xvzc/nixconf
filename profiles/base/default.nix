{
  lib,
  ...
}:
{
  imports = [
    ./system.nix
    { hm.users.default = lib.mkMerge [ ./user.nix ]; }
  ];
}
