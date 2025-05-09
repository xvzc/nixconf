{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    neovim
  ];

  home.shellAliases = {
    vi = "nvim";
  };

  xdg.configFile = {
    "nvim".source = inputs.nvim;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
