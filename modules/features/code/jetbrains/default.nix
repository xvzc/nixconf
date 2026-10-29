{ ctx, lib, ... }:
{
  # ┌────────┐
  # │ COMMON │
  # └────────┘
  nixpkgs.overlays = lib.mkBefore [
    (final: prev: {
      jetbrains = final.mv.tip.jetbrains;
    })
  ];

  home-manager.users.${ctx.user} =
    { ... }:
    {
      home.file.".ideavimrc".source = ./dotfiles/ideavimrc;
    };
}
