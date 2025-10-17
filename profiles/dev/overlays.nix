{
  lib,
  ctx,
  inputs,
  ...
}:
{
  # ┌────────┐
  # │ COMMON │
  # └────────┘
  nixpkgs.overlays = lib.mkBefore [
    (final: prev: {
      nanum-square-neo = final.callPackage ../../pkgs/nanum-square-neo.nix { };

      bash-language-server = final.unstable.bash-language-server;
      gh = final.unstable.gh;
      jetbrains = final.unstable.jetbrains;
      nodejs = final.unstable.nodejs_22;
      slack = final.unstable.slack;
      tmuxPlugins.catppuccin = final.unstable.tmuxPlugins.catppuccin;
      wezterm = final.unstable.wezterm;
      discord = final.unstable.discord;
      firefox = final.unstable.firefox-bin;

      tmux = prev.tmux.overrideAttrs (old: {
        src = prev.fetchFromGitHub {
          owner = "tmux";
          repo = "tmux";
          rev = "449f255f3ef0167c6d226148cdaabac70686dde9";
          sha256 = "sha256-tBh84C7Kt3qjV4oZOcL05dVvBNMFtiCF45uogZvYxiY=";
        };
      });

      _1password-cli = final.unstable._1password-cli;
      _1password-gui = final.unstable._1password-gui;
    })
  ];
}
