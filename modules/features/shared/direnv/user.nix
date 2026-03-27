{ pkgs, ... }:
{
  programs.direnv = {
    enable = true;
    # package = pkgs.unstable.direnv;
    nix-direnv.enable = true;
    enableZshIntegration = true;
    silent = true;
    config = {
      global = {
        load_dotenv = false;
        whitelist = [
          "~/personal"
          "~/work"
        ];
      };
    };
  };
}
