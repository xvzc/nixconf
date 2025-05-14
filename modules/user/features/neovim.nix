{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    neovim-nightly
  ];

  home.shellAliases = {
    vi = "nvim";
  };

  xdg.configFile."nvim-xvzc" = {
    source = inputs.nvim-xvzc;
    recursive = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    NVIM_APPNAME = "nvim-xvzc";
  };
}
