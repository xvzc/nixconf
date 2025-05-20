{ pkgs, inputs, ... }:
let
  nightly = pkgs.neovim-nightly.overrideAttrs (old: {
    meta = old.meta or { } // {
      maintainers = [ ];
    };
  });

in
{
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
    package = nightly;
    defaultEditor = true;
    extraPackages = with pkgs; [
    ];
    extraPython3Packages = pyPkgs: with pyPkgs; [ pynvim ];
    viAlias = true;
    withPython3 = true;
  };
}
