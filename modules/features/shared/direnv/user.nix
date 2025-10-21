{ ... }:
{
  programs.direnv = {
    enable = true;
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
