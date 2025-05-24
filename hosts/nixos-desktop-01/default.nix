{
  pkgs,
  ctx,
  ...
}:
let
  pubkeys = import ../../vars/pubkeys.nix;
in
{
  imports = [
    ./hardware-configuration.nix

    ../../modules/system/nixos/desktop.nix
  ];

  boot.kernelPackages = pkgs.unstable.linuxPackages;
  boot.loader.systemd-boot.enable = true;

  # boot.loader = {
  #   efi = {
  #     canTouchEfiVariables = true;
  #   };
  #   grub = {
  #     enable = true;
  #     efiSupport = true;
  #     configurationLimit = 5;
  #     useOSProber = true;
  #     devices = [ "nodev" ];
  #     # devices = [ "/dev/nvme0n1" "/dev/nvme1n1" ];
  #     extraEntries = ''
  #       menuentry "Reboot" {
  #         reboot
  #       }
  #     '';
  #   };
  # };

  # boot.loader = {
  #   efi.canTouchEfiVariables = true;
  #   grub = {
  #     enable = true;
  #     devices = [ "nodev" ];
  #     efiSupport = true;
  #     useOSProber = true;
  #     # default = "1";
  #     # extraEntriesBeforeNixOS = true;
  #     # extraEntries = ''
  #     #   menuentry "Windows" {
  #     #     insmod part_gpt
  #     #     insmod fat
  #     #     insmod search_fs_uuid
  #     #     insmod chain
  #     #     search --fs-uuid --set=root $FS_UUID
  #     #     chainloader /EFI/Microsoft/Boot/bootmgfw.efi
  #     #   }
  #     # '';
  #   };
  # };

  users.users.${ctx.user} = {
    shell = pkgs.zsh;
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      pubkeys.home.text
    ];

    extraGroups = [
      "wheel"
      "docker"
      "networkmanager"
      "audio"
    ];
  };

  networking = {
    hostName = ctx.host;
    useDHCP = false;
    networkmanager.enable = true;
    networkmanager.ensureProfiles.profiles = {
      # Run `nmcli con up wired` to enable this connection
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

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  desktop = {
    cpu = "amd";
    gpu = "nvidia";
    audio.enable = true;
    windowManager = "hypr";
  };
}
