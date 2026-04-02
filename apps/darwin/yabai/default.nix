{
  lib,
  ctx,
  pkgs,
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
    ./overlays.nix
    ./system.nix
    { home-manager.users.${ctx.user} = ./user.nix; }

    ./jankyborders
  ];

  config = {
    assertions = [
      {
        assertion = pkgs.stdenv.isDarwin;
        message = "The module '${./default.nix}' can only be used on Darwin systems.";
      }
      {
        assertion = !(lib.trivial.xor cfg.enable cfg.border);
        message = "'yabai' and 'border' must be enabled or disabled together.";
      }
    ];
  };
}
