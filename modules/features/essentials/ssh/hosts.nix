# SSH client entries shared by all machines, keyed by host name. Each machine
# gets every entry except its own and those whose `excludeOn` names it, and
# drops a `proxyJump` that names itself. Keys come from pub.nix, whose public
# key files are all in place.
{ pub }:
{
  # GitHub accounts: `git@<account>.github.com:...` picks the key.
  "xvzc.github.com" = {
    hostname = "github.com";
    identitiesOnly = true;
    identityFile = "~/${pub.git.xvzc.path}";
  };

  "work.github.com" = {
    hostname = "github.com";
    identitiesOnly = true;
    identityFile = "~/${pub.git.work.path}";
  };

  # Reached over Tailscale MagicDNS.
  nixos-desktop-01 = {
    hostname = "nixos-desktop-01.tailb7f463.ts.net";
    user = "mizuki";
    HostKeyAlias = "nixos-desktop-01";
    forwardAgent = true;
    identitiesOnly = true;
    identityFile = "~/${pub.host.nixos-desktop-01.path}";
    StrictHostKeyChecking = "no";
    # `ssh nixos-desktop-01` attaches to tmux there (the zsh `ssh` function).
    Tag = "tmux";
  };

  # Windows on the same machine (dual boot), so the same LAN address as
  # NixOS: HostKeyAlias keeps its host key apart in known_hosts.
  windows-desktop-01 = {
    hostname = "172.20.0.100";
    user = "anonymous";
    HostKeyAlias = "windows-desktop-01";
    excludeOn = [ "nixos-desktop-01" ];
  };

  # Reached over Tailscale MagicDNS.
  router = {
    hostname = "router.tailb7f463.ts.net";
    user = "root";
    forwardAgent = true;
    identitiesOnly = true;
    identityFile = "~/${pub.host.router.path}";
    StrictHostKeyChecking = "no";
  };

  # FreeBSD VM on nixos-desktop-01 (features.virt.libvirt there, which sets the
  # address). Reached through the desktop. `vm-guest reinstall` makes a new host key.
  freebsd-vm-01 = {
    hostname = "10.111.111.10";
    user = "nezuko";
    proxyJump = "nixos-desktop-01";
    forwardAgent = true;
    identitiesOnly = true;
    identityFile = "~/${pub.host.vm-shared.path}";
    StrictHostKeyChecking = "no";
    UserKnownHostsFile = "/dev/null";
    LogLevel = "ERROR";
  };
}
