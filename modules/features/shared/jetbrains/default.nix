{
  lib,
  pkgs,
  ctx,
  ...
}:
{
  home-manager.users.${ctx.user} =
    { ... }:
    {
      home.file.".ideavimrc".source = ./ideavimrc;
    };
}
