{
  inputs,
  pkgs,
  ...
}:
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
    defaultEditor = true;
    extraPackages = with pkgs; [
      lua-language-server
      stylua

      nixd
      nixfmt-rfc-style

      bash-language-server
      shellcheck
      shfmt
    ];

    extraPython3Packages =
      pyPkgs: with pyPkgs; [
        pynvim
        python-lsp-server
        black
        flake8
      ];

    viAlias = true;
    withPython3 = true;
  };
}
