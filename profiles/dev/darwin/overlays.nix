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
      im-select = final.callPackage ../../../pkgs/im-select.nix { };
      firefox = final.callPackage ../../../pkgs/firefox.nix { };
      skhd = final.unstable.skhd;
      yabai = final.unstable.yabai;
      jankyborders = final.unstable.jankyborders;
    })
  ];
}
