{
  pkgs,
  config,
  ...
}: {
  programs.git.enable = true;
  programs.git.extraConfig = {
    # We set this option here because .gitconfig can't resolve '~' or '$HOME'
    gpg.ssh.program = "${config.home.homeDirectory}/.1password/op-ssh-sign";
  };
}
