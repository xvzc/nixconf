{
  pkgs,
  ctx,
  lib,
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

  programs._1password-gui.enable = true;
  programs._1password.enable = true;

  home-manager.users.${ctx.user} =
    {
      lib,
      pkgs,
      ctx,
      ...
    }:
    {
      xdg.configFile."1Password/ssh/agent.toml".text =
        # toml
        ''
          [[ssh-keys]]
          vault = "Personal"

          [[ssh-keys]]
          vault = "Work"
        '';
    };
}
