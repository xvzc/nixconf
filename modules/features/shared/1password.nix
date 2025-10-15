{
  lib,
  pkgs,
  ctx,
  ...
}:
{
  programs._1password-gui.enable = true;
  programs._1password.enable = true;

  home-manager.users.${ctx.user} =
    { ... }:
    {
      xdg.configFile."1Password/ssh/agent.toml".text = # toml
        ''
          [[ssh-keys]]
          vault = "Personal"

          [[ssh-keys]]
          vault = "Work"
        '';
    };
}
