{
  lib,
  ctx,
  pkgs,
  ...
}:
{
  imports = [
    { home-manager.users.${ctx.user} = ./user.nix; }
  ];

  # ┌────────┐
  # │ COMMON │
  # └────────┘
  nixpkgs.overlays = [
    (final: prev: {
      discord =
        if pkgs.stdenv.isDarwin then
          final.mv.tip.discord
        else
          final.mv.tip.discord.overrideAttrs (old: {
            postInstall = ''
              ${old.postInstall or ""}
              wrapProgram $out/bin/Discord \
                --add-flags "--ozone-platform=x11"

              ${old.postInstall or ""}
              wrapProgram $out/bin/discord \
                --add-flags "--ozone-platform=x11"
            '';
          });
    })
  ];
}
