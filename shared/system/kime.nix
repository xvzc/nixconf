{
  ...
}:
{
  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
      enable = true;
      type = "kime";
      kime = {
        iconColor = "White";
        extraConfig = # yaml
          ''
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
