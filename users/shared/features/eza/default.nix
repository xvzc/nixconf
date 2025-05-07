{ ... }:
{
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    extraOptions = [
      "--group-directories-first"
      "-g"
    ];
  };


  programs.zsh.shellAliases = {
    l = "ls";
  };
}
