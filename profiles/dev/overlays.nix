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

      clang-tools = prev.clang-tools.overrideAttrs (old: {
        installPhase = ''
          export CPLUS_INCLUDE_PATH="$CPLUS_INCLUDE_PATH:${inputs.assets}/clang/include"
        ''
        + old.installPhase;
      });

      # python312 = prev.python312.override {
      #   packageOverrides = pyfinal: pyprev: {
      #     python-lsp-server = pyprev.python-lsp-server.overridePythonAttrs (old: {
      #       dependencies = old.dependencies ++ [
      #         pyfinal.black
      #       ];
      #     });
      #   };
      # };
      #
      _1password-cli = final.unstable._1password-cli;
      _1password-gui = final.unstable._1password-gui;
    })
  ];
}
