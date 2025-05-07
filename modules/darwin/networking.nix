{
  config,
  lib,
  ctx,
  ...
}:
let
  cfg = config.darwin.networking;
in
with lib;
{
  options.darwin.networking = {
    host = mkOption {
      type = types.str;
      default = ctx.host;
    };
  };

  config = {
    # ┌─────────────┐
    # │ HOST & USER │
    # └─────────────┘
    networking = {
      hostName = cfg.host;
      computerName = cfg.host;
      localHostName = cfg.host;
    };
  };
}
