{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fastfetch
    jq
    ripgrep
    tree
  ];
}
