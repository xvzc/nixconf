{
  git = {
    xvzc = {
      path = ".ssh/xvzc.pub";
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHZZ3IHZk+M07W5NhhKWLq0wmoFQ+xi4Mk8isnJcjVe5";
    };

    work = {
      path = ".ssh/work.pub";
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKtHXAUu74FYAyhBgsPTzvofhr0YDQ1SDWczpupcUjdc";
    };
  };

  host = {
    nixos-desktop-01 = {
      path = ".ssh/nixos-desktop-01.pub";
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIIOn17UKMSvSOCQ6/XH+sqBjbpSbu+r0ECJEnVZ7niy";
    };

    router = {
      path = ".ssh/router.pub";
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJHA2a+fXiKvZfhqcqde7uat+uvx5VhXq0tdVpF1mjzW";
    };

    vm-shared = {
      path = ".ssh/vm-shared.pub";
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILUs47Wzmg8MYHQUFJNDmUVerNuqpsPL9SvKi/ebu1g9";
    };
  };
}
