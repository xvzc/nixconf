{
  lib,
  pkgs,
  ctx,
  ...
}:
{
  xdg.configFile."1Password/ssh/agent.toml".text = # toml
    ''
      [[ssh-keys]]
      vault = "Personal"

      [[ssh-keys]]
      vault = "Work"
    '';
}
