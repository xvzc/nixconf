{
  inputs,
  pub,
  pkgs,
  ...
}:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [ "~/.ssh/config.d/*" ];

    settings = {
      "Host ${pub.ssh.desktop.name}" = {
        hostname = "172.20.0.100";
        user = "mizuki";
        forwardAgent = true;
        identitiesOnly = true;
        StrictHostKeyChecking = "no";
        identityFile = "~/${pub.ssh.desktop.path}";
      };

      "Host ${pub.ssh.router.name}" = {
        hostname = "172.20.0.1";
        user = "root";
        forwardAgent = true;
        identitiesOnly = true;
        StrictHostKeyChecking = "no";
        identityFile = "~/${pub.ssh.router.path}";
      };
    };
  };

  home.file = {
    "${pub.ssh.desktop.path}".text = pub.ssh.desktop.key;
    "${pub.ssh.router.path}".text = pub.ssh.router.key;
  };
}
