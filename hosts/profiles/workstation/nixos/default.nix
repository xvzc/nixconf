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
    ../../../shared/features/chrony.nix
  ];

  environment.systemPackages = with pkgs; [
    lm_sensors
    pamixer
    dig
  ];

  virtualisation.docker.enable = true;
}
