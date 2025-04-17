{
  pkgs,
  curEnv,
  ...
}: {
  time.timeZone = "Asia/Seoul";
  security.pam.enableSudoTouchIdAuth = true;
  # security.pam.services.sudo_local.touchIdAuth = true;
  # security.pam.services.sudo_local.reattach

  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
      nonUS.remapTilde = true;
    };

    # activationScripts are executed every time you boot the system
    # or run `nixos-rebuild` / `darwin-rebuild`.
    # activateSettings -u will reload the settings from the database
    # and apply them to the current session,
    # so we do not need to logout and login again to make the changes take effect.
    activationScripts.postUserActivation.text = ''
      osascript -e 'tell application "Finder" to set desktop picture to POSIX file "/Users/${curEnv.user}/nixfiles/wallpaper.jpeg"'
      sudo nvram StartupMute=%01
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      killall -u ${curEnv.user} cfprefsd
      killall Dock
    '';

    defaults = {
      menuExtraClock.Show24Hour = true; # show 24 hour clock

      dock = {
        autohide = true; # automatically hide and show the dock
        autohide-delay = 0.0;
        autohide-time-modifier = 0.2;
        expose-animation-duration = 0.2;
        tilesize = 48;
        launchanim = false;
        static-only = false;
        showhidden = true;
        orientation = "left";
        show-process-indicators = true;
        show-recents = false; # do not show recent apps in dock
        mru-spaces = false; # do not automatically rearrange spaces based on most recent use.
        expose-group-apps = true; # Group windows by application (required by aerospace)
        persistent-apps = [
          "/Applications/WezTerm.app/"
          "/Applications/Google Chrome.app/"
          "/Applications/Spotify.app"
        ];
      };

      # customize finder
      finder = {
        AppleShowAllExtensions = true; # show all file extensions
        QuitMenuItem = true; # enable quit menu item

        ShowPathbar = true; # show path bar
        ShowStatusBar = true; # show status bar

        AppleShowAllFiles = true;

        ShowExternalHardDrivesOnDesktop = true;
        ShowHardDrivesOnDesktop = false;
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
        KeyRepeat = 2; # normal minimum is 2 (30 ms), maximum is 120 (1800 ms)

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
        #   true: disable this feature (required by aerospace)
        #   false: => enable this feature
        spans-displays = true;
      };

      WindowManager = {
        EnableStandardClickToShowDesktop = true; # Click wallpaper to reveal desktop
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
      }; # CustomSystemPreferences END

      CustomUserPreferences = {
        "com.apple.HIToolbox" = {
          AppleCapsLockSwitchToLastInputSource = false;
        };

        "com.apple.symbolichotkeys" = {
          "AppleSymbolicHotKeys" = {
            "31" = {
              description = "Screenshot";
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
              description = "Mission Control";
              enabled = false;
            };

            "60" = {
              description = "Previous input source";
              enabled = false;
            };

            "61" = {
              description = "Next input source";
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
              description = "Trigger Spotlight";
              enabled = false;
            };

            "65" = {
              description = "Trigger Spotlight finder search";
              enabled = false;
            };

            "118" = {
              description = "Trigger Spotlight finder search";
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
          }; # AppleSymbolicHotKeys END
        }; # com.apple.symbolichotkeys END
      }; # CustomUserPreferences END
    }; # defaults END
  }; # system END
}
