{ pkgs, config, ... }:
{
  git = {
    enable = true;
    extraConfig = {
      gpg.ssh.program = "${config.home.homeDirectory}/.1password/op-ssh-sign";
    };
  };
}
