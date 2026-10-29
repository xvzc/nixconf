{
  lib,
  pkgs,
  ctx,
  config,
  ...
}:
lib.mkIf (config.features.wm.yabai.enable) {
  system.activationScripts.preActivation.text = ''
    csrutil status | grep -q 'enabled.' && echo "SIP must be disabled" && exit 1;
  '';

  environment.systemPackages = [ pkgs.yabai ];

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

  system.activationScripts.postActivation.text = lib.mkOrder 1000 (
    # sh
    ''
      # Restart `yabai`
      sudo ${pkgs.yabai}/bin/yabai --load-sa || true
      launchctl kickstart -k "gui/$(id -u ${ctx.user})/org.nixos.yabai" || true
    ''
  );

  system.nvram.variables = {
    "boot-args" = "-arm64e_preview_abi"; # Allow non-Apple signed binaries
  };

  home-manager.users.${ctx.user} = {
    xdg.configFile = {
      "yabai/yabairc" = {
        source = ./dotfiles/yabairc;
      };

      "yabai/scripts" = {
        source = ./dotfiles/scripts;
        recursive = true;
      };
    };
  };
}
