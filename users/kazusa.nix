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
      "Host ${pub.desktop.name}" = {
        hostname = "172.20.0.100";
        user = "mizuki";
        forwardAgent = true;
        identitiesOnly = true;
        StrictHostKeyChecking = "no";
        identityFile = "~/${pub.desktop.path}";
      };

      "Host ${pub.router.name}" = {
        hostname = "172.20.0.1";
        user = "root";
        forwardAgent = true;
        identitiesOnly = true;
        StrictHostKeyChecking = "no";
        identityFile = "~/${pub.router.path}";
      };
    };
  };

  home.file = {
    "${pub.desktop.path}".text = pub.desktop.key;
    "${pub.router.path}".text = pub.router.key;
  };
}
