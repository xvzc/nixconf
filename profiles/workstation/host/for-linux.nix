{
  lib,
  pkgs,
  ...
}:
let
in
{
  environment.systemPackages = with pkgs; [
    wine
    lm_sensors
    chromedriver
  ];

  # See `man nmcli`
  # See Connection details part  in `man nmcli-examples` for more examples
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
}
