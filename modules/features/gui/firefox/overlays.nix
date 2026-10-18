{
  lib,
  inputs,
  ...
}:
{
  # ┌────────┐
  # │ COMMON │
  # └────────┘
  nixpkgs.overlays = lib.mkBefore [
    (final: prev: {
      firefox = final.mv.tip.firefox-unwrapped;
    })
  ];
}
