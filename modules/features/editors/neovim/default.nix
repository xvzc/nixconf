{
  lib,
  ctx,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    { home-manager.users.${ctx.user} = ./user.nix; }
  ];

  nixpkgs.overlays = [
    (final: prev: {
      neovim-unwrapped = final.unstable.neovim-unwrapped;
    })
  ];
}
