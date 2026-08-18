{ ctx, lib, ... }:
{
  imports = [
    {
      home-manager.users.${ctx.user} = lib.mkMerge [
        ./claude.nix
        ./opencode.nix
        ./pi.nix
      ];
    }
  ];

  # ┌────────┐
  # │ COMMON │
  # └────────┘
  nixpkgs.overlays = [
    (final: prev: {
      claude-code = final.master.claude-code;
      opencode = final.unstable.opencode;
    })
  ];
}
