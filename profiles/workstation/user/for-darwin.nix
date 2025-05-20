{
  pkgs,
  lib,
  ...
}:
with lib;
{
  imports = [
    ../../../shared/user/wm/yabai
  ];

  targets.darwin.keybindings = {
    "₩" = [ "insertText:" ] ++ [ "`" ];
  };

  home.packages = with pkgs; [
    pngpaste
    im-select
  ];
}
