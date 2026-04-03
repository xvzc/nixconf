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
      discord =
        if pkgs.stdenv.isDarwin then
          final.unstable.discord
        else
          final.unstable.discord.overrideAttrs (old: {
            postInstall = ''
              ${old.postInstall or ""}
              wrapProgram $out/bin/Discord \
                --add-flags "--ozone-platform=x11"

              ${old.postInstall or ""}
              wrapProgram $out/bin/discord \
                --add-flags "--ozone-platform=x11"
            '';
          });

      # gemini-cli = final.unstable.gemini-cli;
      # jetbrains = final.unstable.jetbrains;
      #
      # gh = final.unstable.gh;
      # nodejs = final.unstable.nodejs_22;
      # slack = final.unstable.slack;
      # spotify = prev.spotify.overrideAttrs (oldAttrs: {
      #   src =
      #     if (prev.stdenv.isDarwin && prev.stdenv.isAarch64) then
      #       prev.fetchurl {
      #         url = "https://web.archive.org/web/20251029235406/https://download.scdn.co/SpotifyARM64.dmg";
      #         hash = "sha256-0gwoptqLBJBM0qJQ+dGAZdCD6WXzDJEs0BfOxz7f2nQ=";
      #       }
      #     else
      #       oldAttrs.src;
      # });
      # tmux = prev.tmux.overrideAttrs (oldAttrs: {
      #   src = prev.fetchFromGitHub {
      #     owner = "tmux";
      #     repo = "tmux";
      #     rev = "449f255f3ef0167c6d226148cdaabac70686dde9";
      #     sha256 = "sha256-tBh84C7Kt3qjV4oZOcL05dVvBNMFtiCF45uogZvYxiY=";
      #   };
      # });
      # tmuxPlugins.catppuccin = final.unstable.tmuxPlugins.catppuccin;
      # wezterm = final.unstable.wezterm;

      # _1password-cli = final.unstable._1password-cli;
      # _1password-gui = final.unstable._1password-gui;

      # direnv = prev.direnv.overrideAttrs (oldAttrs: {
      #   postPatch = ''
      #     substituteInPlace GNUmakefile --replace-fail " -linkmode=external" ""
      #   '';
      # });

      # kime = final.unstable.kime;
    })
  ];
}
