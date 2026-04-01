{
  inputs,
  auth,
  pkgs,
  ...
}:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [ "~/.ssh/config.d/*" ];

    matchBlocks = {
      "${auth.ssh.desktop.name}" = {
        hostname = "nixos-desktop-01.tailb7f463.ts.net";
        user = "mizuki";
        forwardAgent = true;
        identitiesOnly = true;
        extraOptions = {
          StrictHostKeyChecking = "no";
        };

        identityFile = "~/${auth.ssh.desktop.path}";
      };
    };
  };

  home.file = {
    "${auth.ssh.desktop.path}".text = auth.ssh.desktop.key;
  };
}
