{
  pkgs,
  lib,
  ...
}:
with lib;
{
  imports = [
    ../../_common/wm/yabai
  ];

  targets.darwin.keybindings = {
    "₩" = [ "insertText:" ] ++ [ "`" ];
  };

  home.packages = with pkgs; [
    pngpaste
    im-select
  ];
}
