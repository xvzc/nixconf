{ pkgs, ... }:
{
  home.packages = with pkgs; [
    neovim
  ];

  programs.zsh.shellAliases = {
    vi = "nvim";
    vv = "XDG_CONFIG_HOME=$HOME/personal nvim";
  };

  xdg.configFile = {
    "nvim".source = pkgs.fetchgit {
      url = "https://github.com/xvzc/nvim.git";
      rev = "HEAD";
      sha256 = "zBMMZiSh/QtJYSd4AC70vPu3xbBI32H/fDZ74m4A75Q=";
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
