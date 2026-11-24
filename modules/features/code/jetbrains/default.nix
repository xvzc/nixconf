{ lib, ... }:
{
  # ┌────────┐
  # │ COMMON │
  # └────────┘
  nixpkgs.overlays = lib.mkBefore [
    (final: prev: {
      jetbrains = final.mv.tip.jetbrains;
    })
  ];

  hm.users.default =
    { ... }:
    {
      home.file.".ideavimrc".source = ./dotfiles/ideavimrc;
    };
}
