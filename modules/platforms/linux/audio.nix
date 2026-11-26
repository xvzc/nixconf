# Sound server, chosen per host: `platforms.linux.audio = "pipewire";`. None
# (null) by default. GUI controls (pavucontrol) belong to the desktop.
{
  config,
  lib,
  ctx,
  ...
}:
let
  cfg = config.platforms.linux.audio;
in
{
  options.platforms.linux.audio = lib.mkOption {
    type = lib.types.nullOr (lib.types.enum [ "pipewire" ]);
    default = null;
    description = "Sound server, or null for none.";
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg != null) {
      users.users.${ctx.user}.extraGroups = [ "audio" ];
    })

    # PipeWire, also serving PulseAudio clients.
    (lib.mkIf (cfg == "pipewire") {
      services.pipewire = {
        enable = true;
        audio.enable = true;
        pulse.enable = true;
      };
    })
  ];
}
