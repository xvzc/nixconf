    { ... }:
    {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        config = # toml
          {
            global = {
              # disable_stdin = true;
              load_dotenv = false;
              # hide_env_diff = true;
              # log_format = "-";
            };
          };
        # ''
        #   [global]
        #   disable_stdin = true
        #   load_dotenv = false
        #
        #   [whitelist]
        #   prefix = [ "~/peraonl", "~/work" ]
        # '';
      };
    }

