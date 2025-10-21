{
  pkgs,
  ctx,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    lm_sensors
    pamixer
    dig
  ];

  virtualisation.docker.enable = true;
}
