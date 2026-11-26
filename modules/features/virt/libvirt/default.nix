# libvirt/KVM host with VM guests defined here. A guest boots its OS's official
# VM image, provisioned on first boot from a cloud-init (NoCloud) seed.
#
# A switch defines the network and the guests, and creates a guest's disk when
# it has none. It never starts or stops a guest, and leaves other libvirt
# objects alone. Use `vm-guest` to run the guests: see ./vm-guest.nix.
{
  config,
  lib,
  ctx,
  ...
}:
assert ctx.isLinux;
let
  cfg = config.features.virt.libvirt;

  guestType = lib.types.submodule {
    options = {
      os = lib.mkOption {
        type = lib.types.enum [ "freebsd" ];
        description = "Guest OS; with `version` and `arch`, selects the image in ./images.nix.";
      };
      version = lib.mkOption {
        type = lib.types.str;
        example = "15.1";
        description = "OS version.";
      };
      arch = lib.mkOption {
        type = lib.types.enum [ "x86_64" ];
        default = "x86_64";
        description = "CPU architecture.";
      };
      cpu = lib.mkOption {
        type = lib.types.ints.positive;
        default = 2;
        description = "Number of vCPUs.";
      };
      memory = lib.mkOption {
        type = lib.types.ints.positive;
        default = 4;
        description = "Memory in GiB.";
      };
      disk = lib.mkOption {
        type = lib.types.ints.positive;
        default = 20;
        description = "Disk size in GiB, applied when the disk is created.";
      };
      ip = lib.mkOption {
        type = lib.types.str;
        example = "10.111.111.10";
        description = "Fixed address on the VM network, assigned by DHCP.";
      };
      user = lib.mkOption {
        type = lib.types.str;
        default = ctx.user;
        description = "Login user, in group wheel, with passwordless sudo.";
      };
      authorizedKeys = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
        description = "SSH public keys for `user`.";
      };
      packages = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
        description = "Extra packages to install on first boot (sudo is always).";
      };
      firstBoot = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
        description = "Shell commands to run once, at the end of the first boot.";
      };
    };
  };
in
{
  imports = [
    ./host.nix
    ./guests.nix
    ./vm-guest.nix
  ];

  options.features.virt.libvirt = {
    enable = lib.mkEnableOption "the libvirt/KVM host and its guests";

    bridges = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      example = [ "virbr0" ];
      description = "Other libvirt bridges guests use, trusted and NATed like the network's own.";
    };

    network = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "vmnet";
        description = "libvirt network for the guests (NAT).";
      };
      bridge = lib.mkOption {
        type = lib.types.str;
        default = "virbr1";
        description = "Bridge interface of the network.";
      };
      address = lib.mkOption {
        type = lib.types.str;
        default = "10.111.111.1";
        description = "Host address on the network (a /24).";
      };
      dhcpRange = {
        start = lib.mkOption {
          type = lib.types.str;
          default = "10.111.111.100";
          description = "First address for guests without a fixed one.";
        };
        end = lib.mkOption {
          type = lib.types.str;
          default = "10.111.111.200";
          description = "Last address for guests without a fixed one.";
        };
      };
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/libvirt/nix-vm";
      internal = true;
      description = "Guest disks and applied definitions. Group libvirtd may write, so `vm-guest reinstall` needs no root.";
    };

    guests = lib.mkOption {
      type = lib.types.attrsOf guestType;
      default = { };
      description = "VM guests, by name (also their hostname).";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = lib.mapAttrsToList (name: g: {
      assertion = (import ./images.nix) ? ${g.os}.${g.version}.${g.arch};
      message = "features.virt.libvirt.guests.${name}: no image for ${g.os} ${g.version} ${g.arch} in images.nix.";
    }) cfg.guests;
  };
}
