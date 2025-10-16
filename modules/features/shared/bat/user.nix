{ ... }:
{
  programs.bat = {
    enable = true;
    config = {
      theme = "Visual Studio Dark+";
      pager = "less -FR";
      map-syntax = [
        # "*.jenkinsfile:Groovy"
        # "*.props:Java Properties"
      ];
    };

    # extraPackages = with pkgs; [
    #   # batman
    #   # batgrep
    # ];
  };
}
