{
  lib,
  ctx,
  config,
  ...
}:
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
    ./system.nix
    { home-manager.users.${ctx.user} = ./user.nix; }

    ./jankyborders
  ];

  config = {
    assertions = [
      {
        assertion = !(lib.trivial.xor cfg.enable cfg.border);
        message = "'yabai' and 'border' must be enabled or disabled together.";
      }
    ];
  };
}
