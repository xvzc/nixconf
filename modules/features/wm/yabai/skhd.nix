{
  lib,
  pkgs,
  ctx,
  config,
  ...
}:
lib.mkIf (config.features.wm.yabai.enable) {
  environment.systemPackages = [ pkgs.skhd ];

  launchd.user.agents.skhd = {
    path = [ config.environment.systemPath ];

    serviceConfig.ProgramArguments = [
      "${pkgs.skhd}/bin/skhd"
      "-c"
      "/Users/${ctx.user}/.config/yabai/skhdrc"
    ];
    serviceConfig.KeepAlive = true;
    serviceConfig.ProcessType = "Interactive";
    serviceConfig.StandardErrorPath = "/tmp/skhd_error_log.txt";
  };

  system.activationScripts.postActivation.text = lib.mkOrder 1100 (
    # sh
    ''
      # Restart `skhd`
      launchctl kickstart -k "gui/$(id -u ${ctx.user})/org.nixos.skhd" || true
    ''
  );

  home-manager.users.${ctx.user} = {
    xdg.configFile."yabai/skhdrc" = {
      source = ./dotfiles/skhdrc;
    };
  };
}
