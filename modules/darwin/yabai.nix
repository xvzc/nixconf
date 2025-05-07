{
  config,
  pkgs,
  ctx,
  lib,
  ...
}:
let
  cfg = config.darwin.yabai;
in
with lib;
{
  options.darwin.yabai = {
    enable = mkEnableOption "Whether to enable yabai";
  };

  config = mkIf cfg.enable {
    # ┌──────────┐ 
    # │ PACKAGES │ 
    # └──────────┘ 
    environment.systemPackages = [
      pkgs.skhd
      pkgs.yabai
    ];

    # ┌───────┐ 
    # │ YABAI │ 
    # └───────┘ 
    launchd.user.agents.yabai = {
      serviceConfig.ProgramArguments = [ "${pkgs.yabai}/bin/yabai" ];

      serviceConfig.KeepAlive = true;
      serviceConfig.RunAtLoad = true;
      serviceConfig.StandardErrorPath = "/tmp/yabai_error_log.txt";
      serviceConfig.EnvironmentVariables = {
        PATH = "${pkgs.yabai}/bin:${config.environment.systemPath}";
      };
    };

    launchd.daemons.yabai-sa = {
      script = "${pkgs.yabai}/bin/yabai --load-sa";
      serviceConfig.RunAtLoad = true;
      serviceConfig.KeepAlive.SuccessfulExit = false;
    };

    environment.etc."sudoers.d/yabai".source = pkgs.runCommand "sudoers-yabai" { } ''
      YABAI_BIN="${pkgs.yabai}/bin/yabai"
      SHASUM=$(sha256sum "$YABAI_BIN" | cut -d' ' -f1)
      cat <<EOF >"$out"
      %admin ALL=(root) NOPASSWD: sha256:$SHASUM $YABAI_BIN --load-sa
      EOF
    '';

    system.activationScripts.postUserActivation.text = # sh
      ''
        # Restart `yabai` and `skhd`
        sudo ${pkgs.yabai}/bin/yabai --load-sa || true
        launchctl kickstart -k "gui/$(id -u)/org.nixos.yabai" || true
        launchctl kickstart -k "gui/$(id -u)/org.nixos.skhd" || true
      '';

    # ┌──────┐ 
    # │ SKHD │ 
    # └──────┘ 
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


    system.nvram.variables = {
      "boot-args" = "-arm64e_preview_abi"; # Allow non-Apple signed binaries
    };
  };
}
