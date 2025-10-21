{
  pkgs,
  ctx,
  ...
}:
let
  vars = import ../vars.nix { inherit ctx pkgs; };
in
{
  imports = [
    ../modules/system/linux/hardware-profiles.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages;

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
    };
    grub = {
      enable = true;
      default = 0;
      # version = 2;
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
      vars.ssh.pubkeys.desktop.text
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
      # See `man nmcli`
      # See Connection details part  in `man nmcli-examples` for more examples
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

  hardware.profiles = {
    cpu = "amd";
    gpu = "nvidia";
    audio = "pipewire";
  };

  wm.hyprland.enable = true;

  system.stateVersion = "25.05";
}
