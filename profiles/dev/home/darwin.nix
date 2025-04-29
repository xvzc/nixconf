{
  ctx,
  lib,
  pkgs,
  ...
}@args:
{
  imports = [ ./base.nix ];

  # Remap '₩' to '`' for darwin
  targets.darwin.keybindings = lib.mkIf ctx.isDarwin {
    "₩" = [ "insertText:" ] ++ [ "`" ];
  };

  # ┌───────────────────┐
  # │ DEV home.packages │
  # └───────────────────┘
  home.packages = with pkgs; [
    pngpaste
  ];
}
