{ lib, ... }:
{
  nixpkgs.overlays = lib.mkBefore [
  ];
}
