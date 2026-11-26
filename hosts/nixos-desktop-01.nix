{
  pkgs,
  lib,
  ctx,
  pub,
  config,
  ...
}:
{
  imports = [
    ../modules/features/wm/hyprland
    ../modules/features/essentials/tailscale
    ../modules/features/virt/libvirt
  ];

  config = lib.mkMerge [
    # ┏━━━━━━━━━━━━━━━━┓
    # ┃ MODULE OPTIONS ┃
    # ┗━━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    {

      features.wm.hyprland.enable = true;
      features.essentials.ssh.server = {
        enable = true;
        forwardSudoAuth = true;
        authorizedKeys = [ pub.host.nixos-desktop-01.key ];
      };

      # SpoofDPI integration tests on FreeBSD. Reached as `ssh freebsd-vm-01`
      # (modules/features/essentials/ssh/hosts.nix, which repeats the address).
      features.virt.libvirt = {
        enable = true;
        # libvirt's own default network.
        bridges = [ "virbr0" ];
        guests.freebsd-vm-01 = {
          os = "freebsd";
          version = "15.1";
          ip = "10.111.111.10";
          user = "nezuko";
          authorizedKeys = [ pub.host.vm-shared.key ];
          # SpoofDPI's TUN mode uses a separate FIB. sysctl raises the count now,
          # loader.conf keeps it across reboots (sysrc rejects the dotted name).
          firstBoot = [
            "echo 'net.fibs=\"4\"' >> /boot/loader.conf"
            "sysctl net.fibs=4"
          ];
        };
      };
    }
    # ┏━━━━━━━━┓
    # ┃ SYSTEM ┃
    # ┗━━━━━━━━┻━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    {
      boot.kernelPackages = pkgs.linuxPackages;
      boot.kernelParams = [
        "console=tty3"
      ];

      boot = {
        loader = {
          efi = {
            canTouchEfiVariables = true;
          };
          grub = {
            enable = true;
            default = 0;
            efiSupport = true;
            configurationLimit = 5;
            useOSProber = true;
            devices = [ "nodev" ];
            gfxmodeEfi = "1024x768x32";
            theme = "${pkgs.kdePackages.breeze-grub}/grub/themes/breeze";
            splashImage = null;
          };
        };
      };
    }
    # ┏━━━━━┓
    # ┃ CPU ┃
    # ┗━━━━━┻━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    {
      environment.systemPackages = [
        pkgs.microcode-amd
      ];
    }
    # ┏━━━━━┓
    # ┃ GPU ┃
    # ┗━━━━━┻━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    {
      environment.sessionVariables = {
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        LIBVA_DRIVER_NAME = "nvidia";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        NVD_BACKEND = "direct";
        WLR_NO_HARDWARE_CURSORS = "1";
        NIXOS_OZONE_WL = "1";
      };

      environment.systemPackages = with pkgs; [
        egl-wayland
      ];

      services.xserver.videoDrivers = [ "nvidia" ];
      hardware = {
        opengl.extraPackages = [
          pkgs.nvidia-vaapi-driver
        ];

        nvidia = {
          modesetting.enable = true;
          open = true;
          package = config.boot.kernelPackages.nvidiaPackages.beta;
          nvidiaSettings = true;
          powerManagement.enable = true;
        };

        graphics = {
          enable = true;
        };
      };
    }
    # ┏━━━━━━━┓
    # ┃ AUDIO ┃
    # ┗━━━━━━━┻━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    {
      environment.systemPackages = [
        pkgs.pavucontrol
      ];

      services.pipewire = {
        enable = true;
        audio.enable = true;
        pulse.enable = true;
      };
    }
    # ┏━━━━━━━┓
    # ┃ USERS ┃
    # ┗━━━━━━━┻━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    {
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
    }
    # ┏━━━━━━━━━━━━┓
    # ┃ NETWORKING ┃
    # ┗━━━━━━━━━━━━┻━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    {
      networking = {
        hostName = ctx.host;
        useDHCP = false;
        firewall.enable = true;
        nftables.enable = true;
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
    }
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    { system.stateVersion = "25.05"; }
  ];
}
