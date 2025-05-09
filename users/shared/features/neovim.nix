{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    neovim
  ];

  programs.zsh.shellAliases = {
    vi = "nvim";
    vv = "XDG_CONFIG_HOME=$HOME/personal nvim";
  };

  xdg.configFile = {
    "nvim".source = inputs.nvim;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
