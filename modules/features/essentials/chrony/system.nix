{
  lib,
  pkgs,
  ...
}:
{
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
}
