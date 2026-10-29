{ ... }:
{
  imports = [
    ./claude.nix
    ./opencode.nix
    ./pi.nix
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
