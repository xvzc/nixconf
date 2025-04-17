{
  pkgs,
  curEnv,
  ...
}: let
  user = curEnv.user;
in
  assert curEnv.system == "aarch64-darwin"; {
    imports = [
      ./system.nix
    ];

    system.stateVersion = 5;

    users.users.${user} = {
      name = "${user}";
      home = "/Users/${user}";
      isHidden = false;
      shell = pkgs.zsh;
    };

    environment.etc."pam.d/sudo_local".text = ''
      # Managed by Nix Darwin
      auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so ignore_ssh
      auth       sufficient     pam_tid.so
    '';

    nix-homebrew = {
      enable = true;
      user = "${curEnv.user}";
      enableRosetta = false;
      mutableTaps = true; # disable `brew tap <name>`
    };
  }
