{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  # ┌────────┐
  # │ COMMON │
  # └────────┘
  nixpkgs.overlays = lib.mkBefore [
    (final: prev: {
      _1password-cli = final.mv.tip._1password-cli;
      _1password-gui =
        if pkgs.stdenv.isDarwin then
          final.mv.tip._1password-gui
        else
          final.mv.tip._1password-gui.overrideAttrs (old: {
            postInstall = ''
              ${old.postInstall or ""}
              wrapProgram $out/share/1password/1password \
                --add-flags "--ozone-platform=x11"
            '';
          });
    })
  ];
}
