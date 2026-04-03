{
  config,
  ctx,
  lib,
  ...
}:
lib.mkMerge [
  (lib.optionalAttrs ctx.isDarwin {
    homebrew.casks = lib.mkIf config.nix-homebrew.enable [
      "firefox"
    ];
  })
]
