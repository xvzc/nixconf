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
      skhd = final.unstable.skhd;
      yabai = final.unstable.yabai;
      jankyborders = final.unstable.jankyborders;
    })
  ];
}
