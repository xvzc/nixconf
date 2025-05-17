{ config, pkgs, ... }:
{

  config = {
    environment.systemPackages = with pkgs; [
      sddm-astronaut
      pavucontrol
    ];

    services = {
      xserver = {
        enable = true;
        videoDrivers = [ "nvidia" ];
      };

      displayManager.defaultSession = "hyprland-uwsm";
      displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        package = pkgs.kdePackages.sddm;
        extraPackages = with pkgs; [
          sddm-astronaut
        ];

        theme = "sddm-astronaut-theme";
        settings = {
          Theme = {
            Current = "sddm-astronaut-theme";
          };
        };
      };

      hypridle.enable = true;
    };
  };
}
