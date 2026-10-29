{ ctx, ... }:
{
  home-manager.users.${ctx.user} =
    { pkgs, ... }:
    {
      programs.opencode = {
        enable = true;
      };
    };
}
