{ pkgs, ... }:
###################################################################################
#
#  macOS's System configuration
#
#  All the configuration options are documented here:
#    https://daiderd.com/nix-darwin/manual/index.html#sec-options
#  Incomplete list of macOS `defaults` commands :
#    https://github.com/yannbertrand/macos-defaults
#
#
#  NOTE: Some options are not supported by nix-darwin directly, manually set them:
#   1. To avoid conflicts with neovim, disable ctrl + up/down/left/right to switch spaces in:
#     [System Preferences] -> [Keyboard] -> [Keyboard Shortcuts] -> [Mission Control]
#   2. Disable use Caps Lock as 中/英 switch in:
#     [System Preferences] -> [Keyboard] -> [Input Sources] -> [Edit] -> [Use 中/英 key to switch ] -> [Disable]
{
  security.pam.enableSudoTouchIdAuth = true;
  time.timeZone = "Asia/Seoul";

  system = {
    # activationScripts are executed every time you boot the system
    # or run `nixos-rebuild` / `darwin-rebuild`.
    # activateSettings -u will reload the settings from the database
    # and apply them to the current session,
    # so we do not need to logout and login again to make the changes take effect.
    activationScripts.postUserActivation.text = ''
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    defaults = {
      menuExtraClock.Show24Hour = true; # show 24 hour clock

      dock = {
        autohide = true; # automatically hide and show the dock
        show-recents = false; # do not show recent apps in dock
        mru-spaces = false; # do not automatically rearrange spaces based on most recent use.
        expose-group-apps = true; # Group windows by application

        # customize Hot Corners(触发角, 鼠标移动到屏幕角落时触发的动作)
        # wvous-tl-corner = 2; # top-left - Mission Control
        # wvous-tr-corner = 4; # top-right - Desktop
        # wvous-bl-corner = 3; # bottom-left - Application Windows
        # wvous-br-corner = 13; # bottom-right - Lock Screen
      };

      # customize finder
      finder = {
        AppleShowAllExtensions = true; # show all file extensions
        QuitMenuItem = true; # enable quit menu item

        ShowPathbar = true; # show path bar
        ShowStatusBar = true; # show status bar

        AppleShowAllFiles = true;

        ShowExternalHardDrivesOnDesktop = true;
        ShowHardDrivesOnDesktop = true;
        ShowMountedServersOnDesktop = true;
        ShowRemovableMediaOnDesktop = true;

        _FXSortFoldersFirst = true;
        _FXShowPosixPathInTitle = true; # show full path in finder title

        # When performing a search, search the current folder by default
        FXEnableExtensionChangeWarning = false; # disable warning when changing file extension
        FXDefaultSearchScope = "SCcf";
      };

      # customize trackpad
      trackpad = {
        Clicking = true; # enable tap to click
        Dragging = true;
        TrackpadRightClick = true; # enable two finger right click
        TrackpadThreeFingerDrag = false; # enable three finger drag
      };

      # customize macOS
      NSGlobalDomain = {
        # `defaults read NSGlobalDomain "xxx"`
        "com.apple.swipescrolldirection" = true; # enable natural scrolling(default to true)
        "com.apple.sound.beep.feedback" = 0; # disable beep sound on volume up/down

        AppleInterfaceStyle = "Dark"; # dark mode

        AppleKeyboardUIMode = 3; # Mode 3 enables full keyboard control.
        ApplePressAndHoldEnabled = true; # enable press and hold

        # Key repeat settings
        InitialKeyRepeat = 15; # normal minimum is 15 (225 ms), maximum is 120 (1800 ms)
        KeyRepeat = 3; # normal minimum is 2 (30 ms), maximum is 120 (1800 ms)

        NSAutomaticCapitalizationEnabled = false; # disable auto capitalization
        NSAutomaticDashSubstitutionEnabled = false; # disable auto dash substitution
        NSAutomaticPeriodSubstitutionEnabled = false; # disable auto period substitution
        NSAutomaticQuoteSubstitutionEnabled = false; # disable auto quote substitution
        NSAutomaticSpellingCorrectionEnabled = false; # disable auto spelling correction
        NSNavPanelExpandedStateForSaveMode = true; # expand save panel by default
        NSNavPanelExpandedStateForSaveMode2 = true;

        AppleSpacesSwitchOnActivate = true;
      };

      spaces = {
        # Display have separate spaces
        #   true: disable this feature
        #   false: => enable this feature
        spans-displays = true;
      };

      WindowManager = {
        EnableStandardClickToShowDesktop = false; # Click wallpaper to reveal desktop
        StandardHideDesktopIcons = false; # Show items on desktop
        HideDesktop = false; # Do not hide items on desktop & stage manager
        StageManagerHideWidgets = false;
        StandardHideWidgets = false;
      };

      screensaver = {
        # Require password immediately after sleep or screen saver begins
        askForPassword = true;
        askForPasswordDelay = 0;
      };

      screencapture = {
        location = "~/Desktop";
        type = "png";
      };

      loginwindow = {
        GuestEnabled = false; # disable guest user
        SHOWFULLNAME = true; # show full name in login window
      };

      CustomSystemPreferences = {
        "com.apple.desktopservices" = {
          # Avoid creating .DS_Store files on network or USB volumes
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };

        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };

        # Prevent Photos from opening automatically when devices are plugged in
        "com.apple.ImageCapture".disableHotPlug = true;

        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            "31" = {
              enabled = true;
              value = {
                type = "standard";
                parameters = [
                  115
                  1
                  1310720
                ];
              };
            };

            "36" = {
              # mission control
              enabled = false;
            };

            "60" = {
              # previous input source
              enabled = false;
            };

            "61" = {
              enabled = true;
              value = {
                type = "standard";
                parameters = [
                  32
                  49
                  524288
                ];
              };
            };

            "64" = {
              # spotlight
              enabled = false;
            };

            "65" = {
              # spotlight finder search
              enabled = false;
            };

            "118" = {
              enabled = true;
              value = {
                parameters = [
                  65535
                  18
                  262144
                ];
                type = "standard";
              };
            };
          };
        };
      }; # CustomSystemPreferences END
    }; # defaults END
  }; # system END
}
