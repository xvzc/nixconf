{
  pkgs,
  ctx,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    lm_sensors
    pamixer
    tcpdump
    dig
  ];

  virtualisation.docker.enable = true;
}
