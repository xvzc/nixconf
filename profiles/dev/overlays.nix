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
      nanum-square-neo = final.callPackage ../../pkgs/nanum-square-neo.nix { };

      bash-language-server = final.unstable.bash-language-server;
      firefox = final.unstable.firefox-bin;
      discord = final.unstable.discord;
      gh = final.unstable.gh;
      jetbrains = final.unstable.jetbrains;
      nodejs = final.unstable.nodejs_22;
      slack = final.unstable.slack;
      tmux = prev.tmux.overrideAttrs (old: {
        src = prev.fetchFromGitHub {
          owner = "tmux";
          repo = "tmux";
          rev = "449f255f3ef0167c6d226148cdaabac70686dde9";
          sha256 = "sha256-tBh84C7Kt3qjV4oZOcL05dVvBNMFtiCF45uogZvYxiY=";
        };
      });
      tmuxPlugins.catppuccin = final.unstable.tmuxPlugins.catppuccin;
      wezterm = final.unstable.wezterm;

      _1password-cli = final.unstable._1password-cli;
      _1password-gui = final.unstable._1password-gui;
      zjstatus = inputs.zjstatus.packages.${prev.system}.default;
    })
  ];
}
