{
  lib,
  ctx,
  config,
  ...
}:
assert ctx.isDarwin;
let
  cfg = config.wm.yabai;
in
with lib;
{
  options.wm.yabai = {
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
