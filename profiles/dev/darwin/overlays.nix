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
      aerospace = final.unstable.aerospace;
      im-select = final.callPackage ../../../pkgs/im-select.nix { };
      firefox = final.callPackage ../../../pkgs/firefox.nix { };
      skhd = final.unstable.skhd;
      karabiner-elements = final.unstable.karabiner-elements;
      yabai = final.unstable.yabai;
      jankyborders = final.unstable.jankyborders;
    })
  ];
}
