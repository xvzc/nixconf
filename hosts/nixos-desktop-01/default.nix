{
  pkgs,
  inputs,
  config,
  ctx,
  ...
}:
let
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/host/nixos-host-gui.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # boot.loader.grub = {
  #   # devices = [ "/dev/nvme0n1" ];
  #   enable = true;
  #   efiSupport = true;
  #   device = "nodev";
  # };

  networking.hostName = ctx.host;
  networking.networkmanager.enable = true;

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

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    # displayManager.gdm.enable = true;
    # displayManager.gdm.wayland = true;
    # libinput.enable = true;
  };

  # security.rtkit.enable = true;
  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   alsa.support32Bit = true;
  #   jack.enable = true;
  #   pulse.enable = true;
  #   socketActivation = true;
  # };

  # pulse

  environment.systemPackages = [
    pkgs.pavucontrol
  ];

  nixpkgs.config.pulseaudio = true;

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    nvidiaSettings = true;
    prime.sync.enable = false;
    powerManagement.enable = true;
  };

  hardware = {
    graphics = {
      enable = true;
    };
  };
}
