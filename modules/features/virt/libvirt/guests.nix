# Builds, per guest: the image, the seed ISO and the domain XML; and the
# network XML. ./vm-guest.nix applies them.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.virt.libvirt;
  net = cfg.network;
  images = import ./images.nix;
  yaml = pkgs.formats.yaml { };

  hash = name: builtins.hashString "sha256" name;
  # Stable per name, so a guest keeps its UUID, MAC and so its address.
  mkUuid =
    name:
    let
      h = hash name;
    in
    "${lib.substring 0 8 h}-${lib.substring 8 4 h}-${lib.substring 12 4 h}-${lib.substring 16 4 h}-${lib.substring 20 12 h}";
  mkMac =
    name:
    let
      h = hash "mac:${name}";
    in
    "52:54:00:${lib.substring 0 2 h}:${lib.substring 2 2 h}:${lib.substring 4 2 h}";

  # NoCloud seed, read by FreeBSD's nuageinit on the first boot only (the image
  # has a /firstboot marker). A new seed needs a new disk: `vm-guest reinstall`.
  mkSeed =
    name: g:
    let
      metaData = yaml.generate "meta-data" { local-hostname = name; };
      userData = yaml.generate "user-data" {
        hostname = name;
        ssh_pwauth = false;
        # Installed before users are set up, so sudo works for them.
        packages = [ "sudo" ] ++ g.packages;
        # Without "default", no freebsd/freebsd user is created.
        users = [
          {
            name = g.user;
            groups = "wheel";
            shell = "/bin/sh";
            sudo = "ALL=(ALL) NOPASSWD:ALL";
            lock_passwd = true;
            ssh_authorized_keys = g.authorizedKeys;
          }
        ];
        runcmd = g.firstBoot;
      };
    in
    pkgs.runCommand "${name}-seed.iso" { nativeBuildInputs = [ pkgs.xorriso ]; } ''
      mkdir cidata
      cp ${metaData} cidata/meta-data
      { echo '#cloud-config'; cat ${userData}; } > cidata/user-data
      xorriso -as mkisofs -quiet -volid cidata -joliet -rock -output $out cidata
    '';

  mkGuest =
    name: g:
    let
      img = images.${g.os}.${g.version}.${g.arch};
      disk = "${cfg.stateDir}/${name}.qcow2";
      seed = mkSeed name g;
    in
    {
      inherit disk seed;
      inherit (g) ip;
      size = g.disk;
      mac = mkMac name;
      image = pkgs.fetchurl { inherit (img) url sha256; };
      # BIOS boot (the image also has an EFI partition), serial console only.
      # The seed is in the store: libvirt must not relabel it.
      domain = pkgs.writeText "${name}.xml" ''
        <domain type="kvm">
          <name>${name}</name>
          <uuid>${mkUuid name}</uuid>
          <memory unit="GiB">${toString g.memory}</memory>
          <vcpu>${toString g.cpu}</vcpu>
          <os>
            <type arch="${g.arch}" machine="q35">hvm</type>
            <boot dev="hd"/>
          </os>
          <features><acpi/><apic/></features>
          <cpu mode="host-passthrough"/>
          <clock offset="utc"/>
          <on_poweroff>destroy</on_poweroff>
          <on_reboot>restart</on_reboot>
          <on_crash>destroy</on_crash>
          <devices>
            <disk type="file" device="disk">
              <driver name="qemu" type="qcow2" discard="unmap"/>
              <source file="${disk}"/>
              <target dev="vda" bus="virtio"/>
            </disk>
            <disk type="file" device="cdrom">
              <driver name="qemu" type="raw"/>
              <source file="${seed}">
                <seclabel model="dac" relabel="no"/>
              </source>
              <target dev="sda" bus="sata"/>
              <readonly/>
            </disk>
            <interface type="network">
              <source network="${net.name}"/>
              <mac address="${mkMac name}"/>
              <model type="virtio"/>
            </interface>
            <serial type="pty"><target port="0"/></serial>
            <console type="pty"><target type="serial" port="0"/></console>
            <rng model="virtio"><backend model="random">/dev/urandom</backend></rng>
          </devices>
        </domain>
      '';
    };

  networkXml = pkgs.writeText "${net.name}.xml" ''
    <network>
      <name>${net.name}</name>
      <uuid>${mkUuid "network:${net.name}"}</uuid>
      <forward mode="nat"/>
      <bridge name="${net.bridge}" stp="on" delay="0"/>
      <ip address="${net.address}" prefix="24">
        <dhcp>
          <range start="${net.dhcpRange.start}" end="${net.dhcpRange.end}"/>
    ${lib.concatStrings (
      lib.mapAttrsToList (name: g: ''
        <host mac="${mkMac name}" name="${name}" ip="${g.ip}"/>
      '') cfg.guests
    )}    </dhcp>
      </ip>
    </network>
  '';
in
{
  options.features.virt.libvirt.built = lib.mkOption {
    type = lib.types.raw;
    internal = true;
    readOnly = true;
    description = "Built network XML and per-guest artifacts, for ./vm-guest.nix.";
  };

  config.features.virt.libvirt.built = {
    network = networkXml;
    guests = lib.mapAttrs mkGuest cfg.guests;
  };
}
