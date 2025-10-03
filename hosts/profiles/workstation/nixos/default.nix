{
  lib,
  pkgs,
  ...
}:
{
  # See `man nmcli`
  # See Connection details part  in `man nmcli-examples` for more examples
  # fonts = {
  #   enableDefaultFonts = true;
  #   fontconfig = {
  #     antialias = true;
  #     hinting.enable = true;
  #     hinting.autohint = true;
  #   };
  # };
  imports = [
    ./overlays.nix

    ../../../shared/features/kime.nix
  ];

  environment.systemPackages = with pkgs; [
    lm_sensors
    pamixer
    dig
  ];

  services.chrony = {
    enable = true;
    enableNTS = false;
    servers = [
      "time.cloudflare.com"
      "time.google.com"
      "time.aws.com"
      "time.apple.com"
      "time.facebook.com"
    ];

    initstepslew = {
      enabled = true;
      threshold = 5;
    };
  };

  systemd.services.chronyd = {
    after = [ "network-online.target" ];
  };

  virtualisation.docker.enable = true;
}
