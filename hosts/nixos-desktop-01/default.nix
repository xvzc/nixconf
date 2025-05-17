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

    ../_profiles/workstation
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.unstable.linuxPackages;

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

  services.xserver.videoDrivers = [ "nvidia" ];

  environment.sessionVariables = {
    # WLR_NO_HARDWARE_CURSORS = "1";
    # NIXOS_OZONE_WL = "1";
    # GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  hardware = {
    nvidia = {
      modesetting.enable = true;
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
      nvidiaSettings = true;
      # prime.sync.enable = false;
      powerManagement.enable = true;
    };

    graphics = {
      enable = true;
    };
  };
}
