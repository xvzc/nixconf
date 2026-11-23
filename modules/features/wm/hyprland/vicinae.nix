{
  ctx,
  ...
}:
{
  home-manager.users.${ctx.user} =
    {
      osConfig,
      lib,
      ...
    }:
    lib.mkIf (osConfig.features.wm.hyprland.enable) {
      # Launcher replacing rofi; `vicinae toggle` is bound in hyprland.nix.
      programs.vicinae = {
        enable = true;
        # Runs `vicinae server` as a user service bound to graphical-session.target.
        systemd.enable = true;

        # See `vicinae config default` for all keys.
        settings = {
          # Behave like rofi: close when focus moves away, start fresh each time.
          close_on_focus_loss = true;
          # close_on_focus_loss has no effect with the default "exclusive" interactivity.
          launcher_window.layer_shell.keyboard_interactivity = "on_demand";
          pop_to_root_on_close = true;
          # Esc closes the window at once instead of clearing the search text first.
          escape_key_behavior = "close_window";
          # Ctrl+N / Ctrl+P move down / up.
          keybinding = "emacs";
          # Search while a Hangul syllable is still being composed.
          consider_preedit = true;
          font.normal.family = "JetBrainsMono Nerd Font";
          theme.dark.name = "vicinae-dark";
        };
      };

      # vicinae is a Qt 6 app, but kime only ships a Qt 5 input context plugin, so the
      # global QT_IM_MODULE=kime leaves it without an IME. Use Wayland text-input instead,
      # which kime-wayland serves.
      systemd.user.services.vicinae.Service.Environment = [ "QT_IM_MODULE=wayland" ];
    };
}
