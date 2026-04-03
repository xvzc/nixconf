{
  config,
  lib,
  ...
}:
lib.mkIf (config.features.wm.hypr.enable) {
}
