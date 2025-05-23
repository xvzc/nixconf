{ pkgs, ... }:
{
  home.packages = with pkgs; [
    kime
  ];

  # systemd.user.services.kime-daemon = {
  #   Service = {
  #     Environment = "PATH=${pkgs.kime}/bin";
  #   };
  # };

  xdg.configFile."kime/config.yaml".text =
    # yaml
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
}
