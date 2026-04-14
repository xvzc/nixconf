{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.modules.vm;
  nixvirt-lib = inputs.NixVirt.lib;

  isoGenerators = import ./types;

  guestType = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Name of the VM guest";
      };
      type = lib.mkOption {
        type = lib.types.enum [ "freebsd" ];
        default = "freebsd";
        description = "Guest OS type";
      };
      arch = lib.mkOption {
        type = lib.types.enum [
          "x86_64"
          "aarch64"
        ];
        default = "amd64";
        description = "CPU architecture";
      };
      version = lib.mkOption {
        type = lib.types.str;
        default = "14.1";
        description = "OS version";
      };
      cpu = lib.mkOption {
        type = lib.types.int;
        default = 2;
        description = "Number of vCPUs";
      };
      ram = lib.mkOption {
        type = lib.types.int;
        default = 4;
        description = "Amount of RAM in GB";
      };
      disk = lib.mkOption {
        type = lib.types.int;
        default = 20;
        description = "Disk size";
      };
    };
  };

  mkUuid =
    name:
    let
      hash = builtins.hashString "sha256" name;
    in
    "${builtins.substring 0 8 hash}-${builtins.substring 8 4 hash}-${builtins.substring 12 4 hash}-${builtins.substring 16 4 hash}-${builtins.substring 20 12 hash}";

  defaultPoolName = "default";

  mkDomainDefinition =
    guest:
    let
      isoInfo = isoGenerators.${guest.type} { inherit (guest) version arch; };
      iso = pkgs.fetchurl {
        url = isoInfo.url;
        sha256 = isoInfo.sha256;
      };
    in
    {
      uuid = mkUuid guest.name;
      name = guest.name;
      os = {
        type = {
          arch = guest.arch;
          machine = "q35"; # 라이젠에서도 q35가 표준입니다.
          text = "hvm";
        };
      };
      vcpu = {
        count = guest.cpu;
      };
      memory = {
        count = guest.ram;
        unit = "GiB";
      };
      cpu = {
        mode = "host-passthrough";
      };
      features = {
        acpi = { };
        apic = { };
      };

      devices = {
        disk = [
          {
            type = "file";
            device = "disk";
            driver = {
              name = "qemu";
              type = "qcow2";
            };
            source = {
              file = "/var/lib/libvirt/images/${guest.name}.qcow2";
            };
            target = {
              dev = "vda";
              bus = "virtio";
            };
          }
          {
            type = "file";
            device = "cdrom";
            driver = {
              name = "qemu";
              type = "raw";
            };
            source = {
              file = toString iso;
            };
            target = {
              dev = "sda";
              bus = "sata";
            };
            readonly = true;
          }
        ];

        interface = [
          {
            type = "network";
            source = {
              network = "default";
            };
            model = {
              type = "virtio";
            };
          }
        ];

        serial = [
          {
            type = "pty";
            target = {
              type = "isa-serial";
              port = 0;
            };
          }
        ];
        console = [
          {
            type = "pty";
            target = {
              type = "serial";
              port = 0;
            };
          }
        ];

        graphics = [ ];
        video = [ ];
      };
      # storage_vol = {
      #   pool = defaultPoolName;
      #   volume = "${guest.name}.qcow2";
      # };
      # install_vol = toString iso;
    };

in
{
  options.modules.vm.guests = lib.mkOption {
    type = lib.types.listOf guestType;
    default = [ ];
    description = "List of VM guests";
  };

  config = lib.mkIf (cfg.guests != [ ]) {
    virtualisation.libvirt.connections."qemu:///system" = {
      networks = [
        {
          definition = nixvirt-lib.network.writeXML {
            name = "default";
            uuid = mkUuid "default-network";
            bridge = {
              name = "virbr0";
            };
            forward = {
              mode = "nat";
            };
            ip = {
              address = "10.111.111.1";
              netmask = "255.255.255.0";
              dhcp = {
                range = {
                  start = "10.111.111.2";
                  end = "10.111.111.254";
                };
              };
            };
          };
          active = true;
          restart = null; # Apply changes without restarting the network if it's already active
        }
      ];

      domains = map (guest: {
        definition = nixvirt-lib.domain.writeXML (mkDomainDefinition guest);
        active = true;
        restart = null;
      }) cfg.guests;

      pools = [
        {
          active = true;
          restart = null;

          definition = nixvirt-lib.pool.writeXML {
            name = defaultPoolName;
            uuid = mkUuid "default-pool";
            type = "dir";
            target = {
              path = "/var/lib/libvirt/images";
            };
          };
          # Generate volume definitions for each guest
          volumes = map (guest: {
            present = true;
            definition = nixvirt-lib.volume.writeXML {
              name = "${guest.name}.qcow2";
              capacity = {
                count = guest.disk; # Use an integer for capacity
                unit = "GiB";
              };
              target = {
                format = {
                  type = "qcow2";
                };
              };
            };
          }) cfg.guests;
        }
      ];
    };
  };
}
