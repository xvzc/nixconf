{
  pkgs,
  curEnv,
  ...
}:
let
  commonPkgs = import ../common/pkgs.nix pkgs;
in
assert curEnv.system == "aarch64-darwin";
{

  imports = [
    ./system.nix
    ./home.nix
  ];

  users.users.${curEnv.user} = {
    name = "${curEnv.user}";
    home = "/Users/${curEnv.user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  environment = {
    variables = {
      SSH_AUTH_SOCK = "~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
    };

    systemPackages =
      with pkgs;
      [
        pam-reattach
      ]
      ++ commonPkgs.system;

    # Enable touchId in tmux sessions
    # Ref: https://write.rog.gr/writing/using-touchid-with-tmux/
    etc."pam.d/sudo_local".text = ''
      # Managed by Nix Darwin
      auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so ignore_ssh
      auth       sufficient     pam_tid.so
    '';

  };

  nix-homebrew = {
    enable = true;
    user = "${curEnv.user}";
    enableRosetta = false;
    mutableTaps = true; # disable `brew tap <name>`
  };
}
