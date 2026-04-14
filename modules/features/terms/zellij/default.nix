{
  lib,
  ctx,
  inputs,
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

  nixpkgs.overlays = with inputs; [
    (final: prev: {
      zjstatus = zjstatus.packages.${prev.system}.default;
    })
  ];
}
