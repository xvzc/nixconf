{
  lib,
  inputs,
  ...
}:
{
  # ┌────────┐
  # │ COMMON │
  # └────────┘
  nixpkgs.overlays = lib.mkBefore [
    (final: prev: {
      tmux = prev.tmux.overrideAttrs (oldAttrs: {
        src = prev.fetchFromGitHub {
          owner = "tmux";
          repo = "tmux";
          rev = "449f255f3ef0167c6d226148cdaabac70686dde9";
          sha256 = "sha256-tBh84C7Kt3qjV4oZOcL05dVvBNMFtiCF45uogZvYxiY=";
        };
      });
      tmuxPlugins.catppuccin = final.unstable.tmuxPlugins.catppuccin;
    })
  ];
}
