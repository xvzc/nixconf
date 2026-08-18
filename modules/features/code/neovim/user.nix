{
  inputs,
  pkgs,
  ctx,
  lib,
  ...
}:
let
  # typstLib = rec {
  #   dataDir = if ctx.isLinux then ".local/share" else "Library/Application Support";
  #   pluginDir = "${dataDir}/typst/packages/local";
  #   prompt = rec {
  #     name = "prompt";
  #     version = "0.1.0";
  #     dir = "${pluginDir}/${name}/${version}";
  #   };
  # };
in
{
  # # ┏━━━━━━━━━━━━━━━━━━━━━┓
  # # ┃ TYPST LOCAL PACKAGE ┃
  # # ┗━━━━━━━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  # home.file."${typstLib.prompt.dir}/lib.typ".text = # typst
  #   ''
  #     #let ref(kind: none, style: none, at: none, ..args) = []
  #     #let task(important: none, parallel: none, ..args) = []
  #     #let guide(strict: none, ..args) = []
  #   '';
  #
  # home.file."${typstLib.prompt.dir}/typst.toml".text = # toml
  #   ''
  #     [package]
  #     name = "prompt"
  #     version = "0.1.0"
  #     entrypoint = "lib.typ"
  #   '';

  xdg.configFile."nvim/init.lua".enable = lib.mkForce false;

  xdg.configFile."nvim-xvzc" = {
    source = inputs.nvim-xvzc;
    recursive = true;
  };

  home.sessionVariables = {
    VISUAL = "nvim";
    NVIM_APPNAME = "nvim-xvzc";
  };

  programs.neovim = {
    enable = true;
    # package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
    defaultEditor = true;
    extraPackages = with pkgs; [
      bash-language-server
      shellcheck
      shfmt
    ];

    viAlias = true;

    withPython3 = false;
    withRuby = false;
    withPerl = false;
    withNodeJs = false;
  };
}
