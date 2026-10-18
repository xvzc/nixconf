{
  lib,
  ctx,
  inputs,
  ...
}:
{
  # ┌────────┐
  # │ DARWIN │
  # └────────┘
  nixpkgs.overlays = [
    (final: prev: {
      skhd = final.mv.tip.skhd;
      yabai = final.mv.tip.yabai;
      jankyborders = final.mv.tip.jankyborders;
    })
  ];
}
