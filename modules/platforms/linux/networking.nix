# Networking every Linux host shares: named after the host, nftables firewall,
# and NetworkManager with a DHCP profile for wired ethernet.
{ ctx, ... }:
{
  networking = {
    hostName = ctx.host;
    useDHCP = false;
    firewall.enable = true;
    nftables.enable = true;

    networkmanager.enable = true;
    networkmanager.ensureProfiles.profiles = {
      # See `man nmcli`, and "Connection details" in `man nmcli-examples`.
      # `nmcli con up wired` brings it up.
      wired = {
        connection = {
          auto-connect-priority = 1000;
          id = "wired";
          permissions = "";
          type = "ethernet";
        };
        ipv4 = {
          dns-search = "";
          method = "auto";
        };
        ipv6 = {
          addr-gen-mode = "stable-privacy";
          dns-search = "";
          method = "auto";
        };
      };
    };
  };

  users.users.${ctx.user}.extraGroups = [ "networkmanager" ];
}
