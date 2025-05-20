builtins.mapAttrs
  (k: v: {
    name = k;
    path = ".ssh/${k}.pub";
    text = "${v.algo} ${v.key}";
  })
  {
    home = {
      algo = "ssh-ed25519";
      key = "AAAAC3NzaC1lZDI1NTE5AAAAIIIOn17UKMSvSOCQ6/XH+sqBjbpSbu+r0ECJEnVZ7niy";
    };
    pers = {
      algo = "ssh-ed25519";
      key = "AAAAC3NzaC1lZDI1NTE5AAAAIHZZ3IHZk+M07W5NhhKWLq0wmoFQ+xi4Mk8isnJcjVe5";
    };
    work = {
      algo = "ssh-ed25519";
      key = "AAAAC3NzaC1lZDI1NTE5AAAAIKtHXAUu74FYAyhBgsPTzvofhr0YDQ1SDWczpupcUjdc";
    };
  }
