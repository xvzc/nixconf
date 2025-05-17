{
  pkgs,
  lib,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    pavucontrol
    wine
  ];

  services = {
    xserver = {
      enable = true;
      displayManager.lightdm = {
        enable = true;
        greeters.enso = {
          enable = true;
          blur = true;
        };
      };

      windowManager.bspwm = {
        enable = true;
      };
    };
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
      enable = true;
      type = "kime";
      kime = {
        extraConfig = # yaml
          ''
            indicator:
              icon_color: White
            log:
              global_level: DEBUG
            engine:
              translation_layer: null
              default_category: Latin
              global_category_state: false
              global_hotkeys:
                Super-Space:
                  behavior: !Toggle
                    - Hangul
                    - Latin
                  result: Consume
                Esc:
                  behavior: !Switch Latin
                  result: Bypass
          '';
      };
    };
  };

  programs = {
    _1password.enable = true;
    _1password-gui.enable = true;
  };
}
