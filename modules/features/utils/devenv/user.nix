{
  pkgs,
  lib,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;

  devenvStorePaths = {
    aarch64-darwin = /nix/store/zn9cb7r9zz0l85qcnxmnhap1051rrdxs-devenv-wrapped-2.3.1;
    x86_64-linux = /nix/store/n0kby6a9863lyz004hrmki9gii1ma3nc-devenv-wrapped-2.3.1;
    aarch64-linux = /nix/store/0hvjf326j6gb5chlnf11ndip558bg1j2-devenv-wrapped-2.3.1;
  };

  # package = pkgs.unstable.devenv;
  package = builtins.fetchClosure {
    fromStore = "https://devenv.cachix.org";
    fromPath = devenvStorePaths.${system};
    inputAddressed = true;
  };
in
{
  home.packages = [
    package
  ];

  xdg.configFile."devenv/config.yaml" = {
    text = ''
      version: 1
      tui:
        statusline:
          enabled: false
      shell:
        prompt_prefix: false
    '';
  };

  programs.zsh.initContent = lib.mkMerge [
    (lib.mkOrder 999 # sh
      ''
        eval "$(${package}/bin/devenv hook zsh)"
      ''
    )
  ];
}
