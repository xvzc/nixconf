{ ctx, ... }:
{
  imports = [
    { home-manager.users.${ctx.user} = ./user.nix; }
  ];

  # ┌────────┐
  # │ COMMON │
  # └────────┘
  nixpkgs.overlays = [
    (final: prev: {
      opencode = final.unstable.opencode;
    })
  ];
}
