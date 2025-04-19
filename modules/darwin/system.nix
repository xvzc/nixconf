{
  pkgs,
  env,
  ...
}: {
  stateVersion = 5;

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
    osascript -e 'tell application "Finder" to set desktop picture to POSIX file "/Users/${env.user}/nixfiles/wallpaper.jpeg"'
    sudo nvram StartupMute=%01
    /usr/bin/defaults write com.apple.HIToolbox AppleDictationAutoEnable -bool false
    /usr/bin/defaults write com.apple.speech.recognition.AppleSpeechRecognition.prefs DictationIMShortcut -string ""
    /usr/bin/defaults write com.apple.speech.recognition.AppleSpeechRecognition.prefs DictationIMMasterEnable -bool false
    /usr/bin/defaults write com.apple.speech.recognition.AppleSpeechRecognition.prefs DictationEnabled -bool false

    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    killall -u ${env.user} cfprefsd
    killall Dock
  '';

  defaults = {
    menuExtraClock.Show24Hour = true; # show 24 hour clock

    dock = {
      autohide = true; # automatically hide and show the dock
      tilesize = 46;
      largesize = 52;
      mru-spaces = false; # do not automatically rearrange spaces based on most recent use.
      launchanim = false;
      showhidden = true;
      orientation = "left";
      static-only = false;
      show-recents = false; # do not show recent apps in dock
      magnification = true;
      autohide-delay = 0.1;
      expose-group-apps = true; # Group windows by application (required by aerospace)
      autohide-time-modifier = 0.4;
      expose-animation-duration = 0.5;
      show-process-indicators = true;

      persistent-apps = [
        "${pkgs.wezterm}/Applications/WezTerm.app"
        "${pkgs.google-chrome}/Applications/Google Chrome.app"
        "${pkgs.spotify}/Applications/Spotify.app"
      ];
    };

    # customize finder
    finder = {
      QuitMenuItem = true; # enable quit menu item

      ShowPathbar = true; # show path bar
      ShowStatusBar = true; # show status bar

      AppleShowAllFiles = true;
      AppleShowAllExtensions = true; # show all file extensions

      ShowHardDrivesOnDesktop = false;
      ShowMountedServersOnDesktop = true;
      ShowRemovableMediaOnDesktop = true;
      ShowExternalHardDrivesOnDesktop = true;

      _FXSortFoldersFirst = true;
      _FXShowPosixPathInTitle = true; # show full path in finder title

      # When performing a search, search the current folder by default
      FXDefaultSearchScope = "SCcf";
      FXEnableExtensionChangeWarning = false; # disable warning when changing file extension
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
      "com.apple.keyboard.fnState" = true;
      "com.apple.sound.beep.feedback" = 0; # disable beep sound on volume up/down
      "com.apple.swipescrolldirection" = true; # enable natural scrolling(default to true)

      AppleInterfaceStyle = "Dark"; # dark mode

      AppleKeyboardUIMode = 3; # Mode 3 enables full keyboard control.
      ApplePressAndHoldEnabled = true; # enable press and hold

      # Key repeat settings
      KeyRepeat = 2; # normal minimum is 2 (30 ms), maximum is 120 (1800 ms)
      InitialKeyRepeat = 15; # normal minimum is 15 (225 ms), maximum is 120 (1800 ms)

      NSNavPanelExpandedStateForSaveMode = true; # expand save panel by default
      NSNavPanelExpandedStateForSaveMode2 = true;

      NSAutomaticCapitalizationEnabled = false; # disable auto capitalization
      NSAutomaticDashSubstitutionEnabled = false; # disable auto dash substitution
      NSAutomaticQuoteSubstitutionEnabled = false; # disable auto quote substitution
      NSAutomaticPeriodSubstitutionEnabled = false; # disable auto period substitution
      NSAutomaticSpellingCorrectionEnabled = false; # disable auto spelling correction

      AppleSpacesSwitchOnActivate = true;
    };

    spaces = {
      # Display have separate spaces
      #   true: disable this feature (required by aerospace)
      #   false: => enable this feature
      spans-displays = true;
    };

    WindowManager = {
      HideDesktop = false; # Do not hide items on desktop & stage manager
      StandardHideWidgets = false;
      StageManagerHideWidgets = false;
      StandardHideDesktopIcons = false; # Show items on desktop
      EnableStandardClickToShowDesktop = true; # Click wallpaper to reveal desktop
    };

    screensaver = {
      # Require password immediately after sleep or screen saver begins
      askForPassword = true;
      askForPasswordDelay = 0;
    };

    screencapture = {
      type = "png";
      location = "~/Desktop";
    };

    loginwindow = {
      SHOWFULLNAME = true; # show full name in login window
      GuestEnabled = false; # disable guest user
    };

    CustomSystemPreferences = {
      "com.apple.desktopservices" = {
        # Avoid creating .DS_Store files on network or USB volumes
        DSDontWriteUSBStores = true;
        DSDontWriteNetworkStores = true;
      };

      "com.apple.AdLib" = {
        allowApplePersonalizedAdvertising = false;
      };

      # Prevent Photos from opening automatically when devices are plugged in
      "com.apple.ImageCapture".disableHotPlug = true;
    }; # CustomSystemPreferences END

    CustomUserPreferences = {
      "com.apple.HIToolbox" = {
        AppleFnUsageType = 0;
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
}
