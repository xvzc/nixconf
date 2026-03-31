{
  ssh = {
    personal = rec {
      name = "xvzc";
      path = ".ssh/${name}.pub";
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHZZ3IHZk+M07W5NhhKWLq0wmoFQ+xi4Mk8isnJcjVe5";
    };

    work = rec {
      name = "work";
      path = ".ssh/${name}.pub";
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKtHXAUu74FYAyhBgsPTzvofhr0YDQ1SDWczpupcUjdc";
    };

    desktop = rec {
      name = "desktop";
      path = ".ssh/${name}.pub";
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIIOn17UKMSvSOCQ6/XH+sqBjbpSbu+r0ECJEnVZ7niy";
    };
  };

  _1password =
    { pkgs }:
    {
      signer =
        if pkgs.stdenv.isDarwin then
          "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
        else
          "${pkgs._1password-gui}/bin/op-ssh-sign";

      agent =
        if pkgs.stdenv.isDarwin then
          "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\""
        else
          "~/.1password/agent.sock";
    };
}
