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
      im-select = final.callPackage ../../../../pkgs/im-select.nix { };
      skhd = final.unstable.skhd;
      yabai = final.unstable.yabai;

      # Override firefox with an empty package. 
      # Instead, firefox will be installed with brew.
      # firefox = final.callPackage ../../../../pkgs/none.nix { };
    })
  ];
}
