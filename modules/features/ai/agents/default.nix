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
      claude-code = final.master.claude-code;
    })
  ];
}
