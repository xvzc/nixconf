{
  lib,
  config,
  pkgs,
  ...
}:
lib.mkIf config.features.wm.hyprland.enable {
  environment.systemPackages = with pkgs; [
    dunst
    wl-clipboard
    pavucontrol # waybar's volume module opens it on right-click
  ];

  # Chromium and Electron apps run on Wayland natively.
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  services.dbus.packages = with pkgs; [ xfconf ];
  services = {
    xserver = {
      enable = true;
    };

    displayManager = {
      sessionPackages = [
        pkgs.hyprland
      ];

      ly = {
        enable = true;
        settings = {
          animation = "matrix";
          load = true;
          save = true;
        };
      };
    };
  };

  # environment.pathsToLink = [
  #   "/share/applications"
  #   "/share/xdg-desktop-portal"
  # ];
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = false;
  };

  hm.users.default =
    {
      pkgs,
      config,
      ...
    }:
    {
      programs.zsh.shellAliases = {
        "open" = "nemo";
      };
      home.packages = with pkgs; [
        hyprpicker
        hyprshot
        nemo
      ];

      xdg = {
        portal = {
          enable = true;

          config = {
            hyprland = {
              default = [
                "hyprland"
                "gtk"
              ];
            };
          };

          # Define a portal backend for Gnome
          extraPortals = with pkgs; [
            xdg-desktop-portal-gtk
            # xdg-desktop-portal-wlr
            xdg-desktop-portal-hyprland
            # xdg-desktop-portal
          ];
        };
      };

      home.pointerCursor = {
        gtk.enable = true;
        x11.enable = true;
        package = pkgs.mv.tip.adwaita-icon-theme;
        name = "Adwaita";
        size = 24;
      };

      gtk = {
        enable = true;
        gtk2.enable = true;
        gtk3.enable = true;
        # The pre-26.05 default (home.stateVersion is older): GTK4 apps use the
        # same theme.
        gtk4.theme = config.gtk.theme;
        # colorScheme = "dark";

        theme = {
          package = pkgs.mv.tip.orchis-theme;
          name = "Orchis-Dark-Compact";
        };
        iconTheme = {
          package = pkgs.mv.tip.tela-icon-theme;
          name = "Tela";
        };
      };

      fonts.fontconfig = {
        enable = true;
        defaultFonts.serif = [
          "Noto Sans"
          "Noto Sans CJK KR"
          "JetBrainsMonoNL Nerd Font"
        ];

        defaultFonts.sansSerif = [
          "Noto Sans"
          "Noto Sans CJK KR"
          "JetBrainsMonoNL Nerd Font"
        ];

        defaultFonts.monospace = [
          "JetBrainsMonoNL Nerd Font Mono"
        ];
      };

      wayland.windowManager.hyprland =
        let
          inherit (lib.generators) mkLuaInline;

          mod1 = "SUPER";
          mod2 = "ALT";
          mod3 = "CONTROL";
          terminal = "wezterm";
          # terminal = "env -u WAYLAND_DISPLAY wezterm";

          # hl.bind(keys, dispatcher[, opts]); `dsp` is a raw Lua expression.
          bind = keys: dsp: {
            _args = [
              keys
              (mkLuaInline dsp)
            ];
          };
          bindOpts = keys: dsp: opts: {
            _args = [
              keys
              (mkLuaInline dsp)
              opts
            ];
          };
          exec = cmd: "hl.dsp.exec_cmd(${lib.generators.toLua { } cmd})";

          workspaces = lib.genList (i: i + 1) 10;
          wsKey = ws: toString (lib.mod ws 10);

          anim =
            leaf: enabled: speed: style:
            {
              inherit leaf enabled speed;
              bezier = "default";
            }
            // lib.optionalAttrs (style != null) { inherit style; };

          # Startup commands, run once on the `hyprland.start` event.
          startup = [
            # Ensure environment variable synchronization to prevent compatibility issues in applications such as kime and Ghostty
            { cmd = "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all"; }

            { cmd = "${pkgs.waybar}/bin/waybar"; }
            { cmd = "${pkgs.kime}/bin/kime"; }
            { cmd = "${pkgs._1password-gui}/bin/1password --silent"; }
            # Hidden so its startup window does not flash on the active workspace;
            # the exec rule applies only to the first window, later ones open normally.
            {
              cmd = "${pkgs.discord}/bin/Discord --start-minimized";
              rules.workspace = "special:hidden silent";
            }

            # Launch Spotify hidden so it can initialize in the background
            {
              cmd = "${pkgs.spotify}/bin/spotify";
              rules.workspace = "special:hidden silent";
            }
            # Hide/close its window after startup; Spotify has no reliable Linux start-minimized flag
            {
              cmd = "for i in {1..100}; do hyprctl clients | grep -qi 'class: spotify' && hyprctl dispatch 'hl.dsp.window.close({ window = \"class:spotify\" })' && break; sleep 0.1; done";
            }

            { cmd = "${pkgs.dunst}/bin/dunst"; } # notification backend

            # Disabled: under Wayland + OpenGL (NVIDIA) a hidden instance stalls,
            # so new windows requested through it open very late.
            # {
            #   cmd = "wezterm";
            #   rules.workspace = "special:hidden silent";
            # }

            {
              cmd = "hyprctl setcursor ${toString config.home.pointerCursor.name} ${toString config.home.pointerCursor.size}";
            }
            { cmd = "dconf write /org/gnome/desktop/interface/color-scheme \"'prefer-dark'\""; }
          ];

          toLua = lib.generators.toLua { };
          startupFn =
            "function()\n"
            + lib.concatMapStrings (
              s: "  hl.exec_cmd(${toLua s.cmd}" + lib.optionalString (s ? rules) ", ${toLua s.rules}" + ")\n"
            ) startup
            + "end";
        in
        {
          enable = true;
          package = pkgs.mv.tip.hyprland;
          xwayland.enable = true;
          configType = "lua";
          settings = {
            config = {
              general = {
                layout = "master";
                no_focus_fallback = true;
                col.active_border = {
                  colors = [
                    "rgba(68f938cc)"
                    "rgba(68f938cc)"
                  ];
                  angle = 0;
                };
              };

              master = {
                new_status = "slave";
                orientation = "left";
                mfact = 0.70;
              };

              ecosystem = {
                no_update_news = true;
                no_donation_nag = true;
              };

              debug = {
                disable_logs = false;
              };

              misc = {
                focus_on_activate = true;
                disable_hyprland_logo = true;
                # Keep repainting consistently; VFR can leave flickering artifacts after Waybar tray popups close.
                # vfr = false;
              };

              xwayland = {
                force_zero_scaling = true;
              };

              input = {
                follow_mouse = 2;
                float_switch_override_focus = 0;
              };

              animations = {
                enabled = true;
              };

              decoration = {
                active_opacity = 0.98;
                inactive_opacity = 0.93;
              };
            };

            animation = [
              (anim "workspaces" true 1.5 "slide")
              (anim "windows" true 2 "popin 80%")
              (anim "fade" false 1 null)
              (anim "fadeIn" false 1 null)
              (anim "fadeOut" false 1 null)
              (anim "fadeShadow" false 1 null)
              (anim "fadeDim" false 1 null)
            ];

            on = {
              _args = [
                "hyprland.start"
                (mkLuaInline startupFn)
              ];
            };

            window_rule = [
              {
                name = "noblur";
                match = {
                  class = "^()$";
                  title = "^()$";
                };
                no_blur = true;
              }
              {
                name = "force float for untitled windows";
                match.title = "Not\ titled.*";
                float = true;
                size = "300 200";
              }
              {
                name = "force float for setting windows";
                match.title = "(?i)(setting|preference)";
                float = true;
                size = "300 200";
              }
            ];

            bind = [
              (bind "${mod1} + ${mod2} + ${mod3} + r" "hl.dsp.reload_config()")

              (bind "${mod1} + Return" (exec terminal))
              (bind "${mod1} + q" "hl.dsp.window.close()")
              (bind "${mod1} + F12" ''hl.dsp.workspace.toggle_special("hidden")'')
              (bind "Pause" (exec "hyprlock"))

              # Toggle floating; when the window becomes floating, resize it to 1200x900 and center it.
              (bind "${mod1} + f" ''
                function()
                  hl.dispatch(hl.dsp.window.float())
                  local w = hl.get_active_window()
                  if w and w.floating then
                    hl.dispatch(hl.dsp.window.resize({ x = 1200, y = 900 }))
                    hl.dispatch(hl.dsp.window.center())
                  end
                end'')

              (bind "${mod2} + Space" (exec "vicinae toggle"))
              # (bind "${mod2} + Space" (exec "rofi -show drun -calc-command \"echo -n '{result}' | wl-copy\""))

              (bind "${mod1} + h" ''hl.dsp.focus({ direction = "left" })'')
              (bind "${mod1} + j" ''hl.dsp.focus({ direction = "down" })'')
              (bind "${mod1} + k" ''hl.dsp.focus({ direction = "up" })'')
              (bind "${mod1} + l" ''hl.dsp.focus({ direction = "right" })'')

              (bind "${mod1} + ${mod2} + h" ''hl.dsp.window.swap({ direction = "left" })'')
              (bind "${mod1} + ${mod2} + j" ''hl.dsp.window.swap({ direction = "down" })'')
              (bind "${mod1} + ${mod2} + k" ''hl.dsp.window.swap({ direction = "up" })'')
              (bind "${mod1} + ${mod2} + l" ''hl.dsp.window.swap({ direction = "right" })'')

              # "$mod1 $mod3, s, exec, rofi -show drun"
              (bind "${mod1} + ${mod3} + s" (exec "hyprshot -m region --clipboard-only"))
              (bind "${mod1} + ${mod2} + ${mod3} + s" (exec "hyprshot -m region -o ~/.screenshots"))

              (bindOpts "${mod1} + mouse:272" "hl.dsp.window.drag()" { mouse = true; })
              (bindOpts "${mod1} + mouse:273" "hl.dsp.window.resize()" { mouse = true; })
            ]
            ++ map (ws: bind "${mod1} + ${wsKey ws}" "hl.dsp.focus({ workspace = ${toString ws} })") workspaces
            ++ map (
              ws: bind "${mod1} + ${mod2} + ${wsKey ws}" "hl.dsp.window.move({ workspace = ${toString ws} })"
            ) workspaces;
          };
        };
    };
}
