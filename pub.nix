{
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

  router = rec {
    name = "router";
    path = ".ssh/${name}.pub";
    key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJHA2a+fXiKvZfhqcqde7uat+uvx5VhXq0tdVpF1mjzW";
  };
}
