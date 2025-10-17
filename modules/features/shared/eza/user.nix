{ lib, pkgs, ... }:
{
  programs.eza = {
    enable = true;
    # enableZshIntegration = true;
    extraOptions = [
      "--group-directories-first"
      "-g"
    ];
  };

  programs.zsh.shellAliases = {
    l = "${pkgs.eza}/bin/eza";
    ll = "${pkgs.eza}/bin/eza -alX";
    la = "${pkgs.eza}/bin/eza -a";
  };

  home.sessionVariables = {
    EZA_COLORS = lib.strings.concatStrings [
      "da=37:di=34:" # Directories
      "gu=97;1:gn=2;3:gR=90;2;3:" # Groups
      "uu=97;1:un=2;3:uR=90;2;3:" # Users
      "sc=93:bu=93:"
    ];
  };
}
