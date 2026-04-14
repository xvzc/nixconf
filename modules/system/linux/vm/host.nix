{
  config,
  lib,
  pkgs,
  ctx,
  ...
}:
let
  cfg = config.modules.vm.host;
in
{
  options.modules.vm.host = {
    enable = lib.mkEnableOption "VM host support";
  };

  config = lib.mkIf cfg.enable {
    users.users.${ctx.user}.extraGroups = [
      "libvirtd"
    ];

    environment.variables = {
      LIBVIRT_DEFAULT_URI = "qemu:///system";
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/libvirt/images 0755 root root -"
    ];

    virtualisation.libvirt.enable = true;
    virtualisation.libvirtd = {
      enable = true;
      package = pkgs.libvirt;
      # onBoot = "start";
      # onShutdown = "shutdown";
      extraConfig = ''
        firewall_backend = "iptables"
      '';
    };

    environment.systemPackages = with pkgs; [
      libvirt
      virt-manager
      virt-viewer
    ];

    users.groups.libvirtd = { };
  };
}
