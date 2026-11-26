{
  pkgs,
  lib,
  pub,
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
      platforms.linux = {
        hardware = {
          cpu = "amd";
          gpu = "nvidia";
        };
        audio = "pipewire";
      };
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
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    { system.stateVersion = "25.05"; }
  ];
}
