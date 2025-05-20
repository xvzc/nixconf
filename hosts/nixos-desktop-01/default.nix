{
  pkgs,
  ctx,
  ...
}:
let
in
{
  imports = [
    ./hardware-configuration.nix

    ../../modules/nixos/desktop.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.unstable.linuxPackages;

  users.users.${ctx.user} = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "networkmanager"
      "audio"
    ];
  };

  desktop = {
    cpu = "amd";
    gpu = "nvidia";
    audio.enable = true;
    windowManager = "bspwm";
  };

  networking.useDHCP = false;
  networking.hostName = ctx.host;
  networking = {
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
      home-wifi = {
        connection = {
          id = "home-wifi";
          permissions = "";
          type = "wifi";
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
        wifi = {
          mac-address-blacklist = "";
          mode = "infrastructure";
          ssid = "c8bad2e1";
        };
        wifi-security = {
          # Run `nmcli con modify home-wifi 'wifi-sec.psk'`
          # to set the wifi password. or via `nmtui`
          auth-alg = "open";
          key-mgmt = "wpa-psk";
          psk = "$WIFI_PASSWORD";
        };
      };
    };
  };
}
