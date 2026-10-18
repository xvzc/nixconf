{ ctx, lib, ... }:
{
  imports = [
    {
      home-manager.users.${ctx.user} = lib.mkMerge [
        ./claude.nix
        ./opencode.nix
      ];
    }
  ];

  # ┌────────┐
  # │ COMMON │
  # └────────┘
  nixpkgs.overlays = [
    (final: prev: {
      claude-code = final.mv.latest.claude-code;
      opencode = final.mv.tip.opencode;
    })
  ];
}
