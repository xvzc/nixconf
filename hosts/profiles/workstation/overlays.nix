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
  nixpkgs.overlays = [
    (final: prev: {
      nanum-square-neo = final.callPackage ../../../pkgs/nanum-square-neo.nix { };

      bash-language-server = final.unstable.bash-language-server;
      gh = final.unstable.gh;
      jetbrains = final.unstable.jetbrains;
      nodejs = final.unstable.nodejs_22;
      slack = final.unstable.slack;
      tmuxPlugins.catppuccin = final.unstable.tmuxPlugins.catppuccin;
      wezterm = final.unstable.wezterm;
      _1password-cli = final.unstable._1password-cli;
    })
  ];
}
