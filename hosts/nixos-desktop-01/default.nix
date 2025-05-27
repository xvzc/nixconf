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

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
    };
    grub = {
      enable = true;
      default = 0;
      version = 2;
      efiSupport = true;
      configurationLimit = 5;
      useOSProber = true;
      devices = [ "nodev" ];
      gfxmodeEfi = "1368x768";
    };
  };

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

  system.stateVersion = "25.05";
}
