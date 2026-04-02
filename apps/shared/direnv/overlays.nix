{
  lib,
  ...
}:
{
  nixpkgs.overlays = lib.mkBefore [
    (final: prev: {
      direnv = prev.direnv.overrideAttrs (oldAttrs: {
        postPatch = ''
          substituteInPlace GNUmakefile --replace-fail " -linkmode=external" ""
        '';
      });
    })
  ];
}
