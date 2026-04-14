{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  mkPlugin =
    loc: attrs:
    {
      _props = {
        location = loc;
      };
    }
    // attrs;
  mkEmptyPlugin = loc: mkPlugin loc { };
  mkBind = key: attrs: {
    bind = {
      _args = [ key ];
    }
    // attrs;
  };
in
{

  xdg.configFile."zellij/sessions" = {
    source = ./_files/sessions;
    recursive = true;
  };

  xdg.configFile."zellij/scripts" = {
    source = ./_files/scripts;
    recursive = true;
  };

  programs.zellij = {
    enable = true;
  };

  programs.zellij.settings = {
    pane_frames = true;
    show_startup_tips = false;
    advanced_mouse_actions = false;

    web_client = {
      font = "monospace";
    };

    load_plugins = { };

    plugins = {
      about = mkEmptyPlugin "zellij:about";
      compact-bar = mkEmptyPlugin "zellij:compact-bar";
      configuration = mkEmptyPlugin "zellij:configuration";
      plugin-manager = mkEmptyPlugin "zellij:plugin-manager";
      session-manager = mkEmptyPlugin "zellij:session-manager";
      status-bar = mkEmptyPlugin "zellij:status-bar";
      strider = mkEmptyPlugin "zellij:strider";
      tab-bar = mkEmptyPlugin "zellij:tab-bar";

      welcome-screen = mkPlugin "zellij:session-manager" {
        welcome_screen = false;
      };

      filepicker = mkPlugin "zellij:strider" {
        cwd = "/";
      };

      zjstatus = mkPlugin "file:${pkgs.zjstatus}/bin/zjstatus.wasm" {
        format_left = "{mode} #[fg=#89B4FA,bold]{session}";
        format_center = "{tabs}";
        format_right = "";
        # format_right = "{command_git_branch} {datetime}";
        format_space = "";

        tab_normal = "#[fg=#6C7086] {name} ";
        tab_active = "#[fg=#9399B2,bold] {name} ";
        tab_fullscreen = "#[fg=#f9e2af,bold] {name} (Z) ";
        tab_sync = "#[fg=#a6e3a1,bold] {name} (S) ";

        border_enabled = false;
        border_char = "─";
        border_format = "#[fg=#6C7086]{char}";
        border_position = "top";

        hide_frame_for_single_pane = false;

        mode_normal = "#[bg=blue] ";
        mode_tmux = "#[bg=#ffc387] ";

        command_git_branch_command = "git rev-parse --abbrev-ref HEAD";
        command_git_branch_format = "#[fg=blue] {stdout} ";
        command_git_branch_interval = "10";
        command_git_branch_rendermode = "static";

        datetime = "#[fg=#6C7086,bold] {format} ";
        datetime_format = "%A, %d %b %Y %H:%M";
        datetime_timezone = "Asia/Seoul";
      };
    };

    keybinds = {
      normal = {
        _props = {
          clear-defaults = true;
        };
        _children = [
          (mkBind "Ctrl a" {
            SwitchToMode = "tmux";
          })
          (mkBind "F12" {
            ToggleFloatingPanes = [ ];
          })
          (mkBind "Ctrl h" {
            MoveFocus = "Left";
            SwitchToMode = "Normal";
          })
          (mkBind "Ctrl l" {
            MoveFocus = "Right";
            SwitchToMode = "Normal";
          })
          (mkBind "Ctrl j" {
            MoveFocus = "Down";
            SwitchToMode = "Normal";
          })
          (mkBind "Ctrl k" {
            MoveFocus = "Up";
            SwitchToMode = "Normal";
          })
        ];
      };

      tmux = {
        # Represents repeated KDL bind nodes using the _children list structure
        # Passes key arguments via _args to correctly render KDL syntax
        _props = {
          clear-defaults = true;
        };
        _children = [
          (mkBind "Esc" {
            SwitchToMode = "normal";
          })
          (mkBind "Ctrl c" {
            SwitchToMode = "normal";
          })
          (mkBind "1" {
            GoToTab = 1;
            SwitchToMode = "Normal";
          })
          (mkBind "2" {
            GoToTab = 2;
            SwitchToMode = "Normal";
          })
          (mkBind "3" {
            GoToTab = 3;
            SwitchToMode = "Normal";
          })
          (mkBind "4" {
            GoToTab = 4;
            SwitchToMode = "Normal";
          })
          (mkBind "5" {
            GoToTab = 5;
            SwitchToMode = "Normal";
          })
          (mkBind "6" {
            GoToTab = 6;
            SwitchToMode = "Normal";
          })
          (mkBind "7" {
            GoToTab = 7;
            SwitchToMode = "Normal";
          })
          (mkBind "8" {
            GoToTab = 8;
            SwitchToMode = "Normal";
          })
          (mkBind "9" {
            GoToTab = 9;
            SwitchToMode = "Normal";
          })
          (mkBind "e" {
            EditScrollback = [ ];
            SwitchToMode = "Normal";
          })
          (mkBind "m" {
            SwitchToMode = "move";
          })
          (mkBind "r" {
            SwitchToMode = "resize";
          })
          (mkBind "c" {
            NewTab = [ ];
            SwitchToMode = "Normal";
          })
          (mkBind "Enter" {
            NewPane = [ ];
            SwitchToMode = "Normal";
          })
        ];
      };

      shared_except = {
        _args = [ "locked" ];
        _children = [
          (mkBind "F12" {
            SwitchToMode = "Locked";
          })
        ];
      };
    };
  };

  programs.zellij.layouts = {
    default = {
      layout = {
        default_tab_template = {
          _children = [
            {
              pane = {
                _props = {
                  size = 1;
                  borderless = true;
                };
                plugin = {
                  _props = {
                    location = "zjstatus";
                  };
                };
              };
            }
            { "children" = { }; }
          ];
        };
      };
    };
  };
}
