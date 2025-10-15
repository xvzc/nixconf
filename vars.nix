{
  pkgs,
  ctx,
  ...
}:
{
  ssh = {
    pubkeys =
      builtins.mapAttrs
        (k: v: {
          name = k;
          path = ".ssh/${k}.pub";
          text = "${v.algo} ${v.key}";
        })
        {
          personal = {
            algo = "ssh-ed25519";
            key = "AAAAC3NzaC1lZDI1NTE5AAAAIHZZ3IHZk+M07W5NhhKWLq0wmoFQ+xi4Mk8isnJcjVe5";
          };

          work = {
            algo = "ssh-ed25519";
            key = "AAAAC3NzaC1lZDI1NTE5AAAAIKtHXAUu74FYAyhBgsPTzvofhr0YDQ1SDWczpupcUjdc";
          };

          desktop = {
            algo = "ssh-ed25519";
            key = "AAAAC3NzaC1lZDI1NTE5AAAAIIIOn17UKMSvSOCQ6/XH+sqBjbpSbu+r0ECJEnVZ7niy";
          };

        };

    _1password = {
      signer =
        {
          darwin = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
          linux = "${pkgs._1password-gui}/bin/op-ssh-sign";
        }
        .${ctx.os};

      agent =
        {
          darwin = "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
          linux = "~/.1password/agent.sock";
        }
        .${ctx.os};
    };
  };
}
