{ pkgs, ... }:
{
  home.packages = [
    pkgs.oh-my-fish
  ];

  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "fasd";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-fasd";
          rev = "38a5b6b6011106092009549e52249c6d6f501fba";
          sha256 = "06v37hqy5yrv5a6ssd1p3cjd9y3hnp19d3ab7dag56fs1qmgyhbs";
        };
      }
    ];
  };
}
