{
  pkgs,
  lib,
  ctx,
  auth,
  config,
  ...
}:
{
  imports = [
    ../modules/features/wm/hypr
    ../modules/features/core/tailscale
  ];

  config = lib.mkMerge [
    # ┏━━━━━━━━━━━━━━━━┓
    # ┃ MODULE OPTIONS ┃
    # ┗━━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    {

      features.wm.hypr = {
        enable = true;
        withRofi = true;
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

      security.pam.sshAgentAuth.enable = true;
      security.pam.services.sudo.sshAgentAuth = true;
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
        openssh.authorizedKeys.keys = [
          auth.ssh.desktop.key
        ];

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

      services.openssh = {
        enable = true;
        ports = [ 22 ];
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
        };
      };
    }
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    { system.stateVersion = "25.05"; }
  ];
}
