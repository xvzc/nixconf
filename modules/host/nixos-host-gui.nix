{
  pkgs,
  ...
}:
{
  imports = [
    ./base/gui.nix
  ];

  environment.systemPackages = with pkgs; [
    sddm-astronaut
  ];

  services.openssh.enable = true;

  services.displayManager.defaultSession = "hyprland-uwsm";
  services.displayManager.sddm = {
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

  services.hypridle.enable = true;

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  programs.hyprlock.enable = true;
  programs.waybar.enable = true;

  programs._1password.enable = true;
  programs._1password-gui.enable = true;
}
