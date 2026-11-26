{
  config,
  lib,
  ctx,
  ...
}:
let
  cfg = config.features.virt.libvirt;
  bridges = [ cfg.network.bridge ] ++ cfg.bridges;
in
lib.mkIf cfg.enable {
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  users.users.${ctx.user}.extraGroups = [ "libvirtd" ];
  environment.variables.LIBVIRT_DEFAULT_URI = "qemu:///system";

  # setgid, so files made by the service (root) and by `vm-guest` (the user) share
  # the group. Others may traverse: qemu runs as its own user.
  systemd.tmpfiles.rules = [ "d ${cfg.stateDir} 2775 root libvirtd -" ];

  # Guests get DHCP and DNS from libvirt's dnsmasq on the bridge, and reach
  # out through NAT.
  networking.firewall.trustedInterfaces = bridges;
  networking.nat = {
    enable = true;
    internalInterfaces = bridges;
  };
}
