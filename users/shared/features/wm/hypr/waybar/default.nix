{ pkgs, ... }:
{
  xdg.configFile."waybar/scripts" = {
    source = ./scripts;
    recursive = true;
  };

  programs.waybar = {
    enable = true;
    settings = [
      {
        layer = "top";
        spacing = 0;
        height = 0;
        margin-top = 0;
        margin-right = 0;
        margin-bottom = 0;
        margin-left = 0;
        modules-left = [
          "pulseaudio"
          "disk"
          "memory"
          "custom/cputemp"
          "network"
        ];
        modules-center = [
          "hyprland/workspaces"
        ];
        modules-right = [
          "tray"
          # "cpu_text"
          "custom/whoami"
          "clock"
        ];
        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          tooltip = false;
          "persistent-workspaces" = {
            "1" = [ ];
            "2" = [ ];
            "3" = [ ];
            "4" = [ ];
            "5" = [ ];
            "6" = [ ];
            "7" = [ ];
            "8" = [ ];
            "9" = [ ];
            "10" = [ ];
          };
        };
        tray = {
          spacing = 7;
          tooltip = false;
        };

        clock = {
          format = "󰭧 {:%a %d %b %H:%M}";
          tooltip = false;
        };

        "custom/cputemp" = {
          format = " {text}°C";
          return-type = "json";
          exec = "~/.config/waybar/scripts/cputemp";
          interval = 1;
        };

        "custom/whoami" = {
          format = " {text}";
          return-type = "json";
          exec = "~/.config/waybar/scripts/whoami";
          interval = 10;
        };

        memory = {
          format = " {percentage:2}%";
          interval = 2;
          states = {
            critical = 80;
          };
        };

        disk = {
          interval = 5;
          format = " {percentage_free:2}%";
          path = "/";
        };

        network = {
          format-wifi = "󰘊 connected";
          format-ethernet = "󰒢 connected";
          format-disconnected = "󰞃 no-connection";
          interval = 5;
          # min-length = 15;
          tooltip-format = "{bandwidthDownBits}";
          # tooltip = false;
        };

        pulseaudio = {
          scroll-step = 3;
          max-volume = 99;
          format = "{icon} {volume:2}%";
          format-muted = "{icon} nil";
          format-icons = {
            default = [ "󰕾" ];
          };

          format-bluetooth = "vol {volume:2}%";
          on-click = "pamixer -t";
          on-click-right = "pavucontrol";

          tooltip = false;
        };
      }
    ];

    style = # css
      ''
        @define-color accent-bright rgb(249, 226, 176);
        @define-color accent-dim rgb(133, 118, 93);

        @define-color bg-bright rgb(54, 52, 48);
        @define-color bg-dim rgb(28, 27, 24);

        @define-color border-dim rgb(107, 112, 134);
        @define-color border-bright rgb(156, 149, 139);

        @define-color critical rgb(227, 105, 89);
        @define-color urgent rgb(231, 138, 78);
        @define-color text rgb(61, 61, 61);

        * {
            border: none;
            border-radius: 0;
            min-height: 0;
            font-family: "JetBrainsMono Nerd Font Propo";
            font-weight: 500;
            font-size: 14px;
            padding: 0;
        }

        window#waybar {
            background: @bg-dim;
            /* border: 2px solid @border-dim; */
        }

        tooltip {
            background-color: @bg-dim;
            border: 2px solid @border-dim;
        }

        #clock,
        #tray,
        #custom-cputemp,
        #custom-whoami,
        #memory,
        #network,
        #disk,
        #pulseaudio {
            margin: 6px 6px 6px 6px;
            padding: 2px 8px;
        }

        #custom-cputemp.normal,
        #memory,
        #network,
        #disk,
        #pulseaudio {
            background-color: @accent-bright;
            border: 2px solid @accent-dim;
            color: @text;
        }

        #custom-whoami,
        #clock {
            background-color: @bg-bright;
            border: 2px solid @accent-dim;
            color: @accent-bright;
        }

        #tray {
            /* background-color: @accent-bright; */
            /* border: 2px solid @accent-dim; */
        }

        #custom-cputemp.critical,
        #memory.critical {
            background-color: @accent-bright;
            border: 2px solid @accent-dim;
            color: @critical;
        }

        #workspaces {
            all: initial;
            margin: 6px 0px 6px 6px;
            border: 1px solid @accent-dim;
            background-color: @bg-bright;
        }

        #workspaces button {
          box-shadow: none;
          text-shadow: none;
          padding: 2px;
          border-radius: 0px;
          border: 1px solid @accent-dim;

          color: @accent-bright;
        }

        #workspaces button.active {
          background: @accent-bright;
          color: @bg-dim;
        }

        #workspaces button.urgent {
          background: @urgent;
          color: @bg-dim;
        }

        #workspaces button:hover {
          background: @accent-bright;
          color: @bg-dim;
        }
      '';
  };
}
