{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.features.wm;
in
lib.optionalAttrs (cfg.enable && cfg.wm.provider == "aerospace") {
  services.aerospace = {
    enable = false;
  };
}
