{
  lib,
  ctx,
  config,
  ...
}:
assert ctx.isDarwin;
with lib;
{
  options.features.wm.yabai = {
    enable = mkEnableOption "Whether to enable 'yabai'";
    border = mkEnableOption "Whether to enable 'jankyborder'";
  };

  imports = [
    ./overlays.nix
    ./system.nix
    { home-manager.users.${ctx.user} = ./user.nix; }

    ./jankyborders
  ];
}
