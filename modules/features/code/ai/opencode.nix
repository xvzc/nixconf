{ ctx, ... }:
{
  home-manager.users.${ctx.user} =
    { pkgs, ... }:
    {
      programs.opencode = {
        enable = true;
        # Global instructions, deployed as ~/.config/opencode/AGENTS.md.
        context = ./dotfiles/system.md;
      };
    };
}
