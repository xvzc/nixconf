{
  lib,
  pkgs,
  ctx,
  ...
}:
{
  # ┌───────────────────────┐
  # │ MACOS_SYSTEM_SETTINGS │
  # └───────────────────────┘
  system.primaryUser = ctx.user;
  system.defaults.loginwindow = {
    autoLoginUser = ctx.user;
    SHOWFULLNAME = false; # show full name in login window
    GuestEnabled = false; # disable guest user
  };

  # - DOCK - #
  system.defaults.dock = {
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

    # Disable all hot corners
    wvous-bl-corner = 1;
    wvous-br-corner = 1;
    wvous-tl-corner = 1;
    wvous-tr-corner = 1;
  };

  # - FINDER - #
  system.defaults.finder = {
    QuitMenuItem = false; # enable quit menu item

    ShowPathbar = true; # show path bar
    ShowStatusBar = true; # show status bar

    AppleShowAllFiles = true;
    AppleShowAllExtensions = true; # show all file extensions

    ShowHardDrivesOnDesktop = false;
    ShowMountedServersOnDesktop = true;
    ShowRemovableMediaOnDesktop = true;
    ShowExternalHardDrivesOnDesktop = true;

    _FXSortFoldersFirst = true;
    _FXShowPosixPathInTitle = false; # show full path in finder title

    FXDefaultSearchScope = "SCcf"; # When performing a search, search the current folder.
    FXPreferredViewStyle = "Nlsv"; # list view.
    FXEnableExtensionChangeWarning = false;
  };

  system.defaults.NSGlobalDomain = {
    NSNavPanelExpandedStateForSaveMode = true; # expand save panel by default
    NSNavPanelExpandedStateForSaveMode2 = true;
  };

  # - DISPLAY - #
  system.defaults.spaces = {
    # Displays have separate spaces
    #   true: disable this feature
    #   false: => enable this feature (required by yabai)
    spans-displays = false;
  };

  system.defaults.WindowManager = {
    HideDesktop = false; # Do not hide items on desktop & stage manager
    StandardHideWidgets = false;
    StageManagerHideWidgets = false;
    StandardHideDesktopIcons = false; # Show items on desktop
    EnableStandardClickToShowDesktop = true; # Click wallpaper to reveal desktop
  };

  system.defaults.screensaver = {
    # Require password immediately after sleep or screen saver begins
    askForPassword = true;
    askForPasswordDelay = 0;
  };

  system.defaults.NSGlobalDomain = {
    AppleInterfaceStyle = "Dark"; # dark mode
    AppleSpacesSwitchOnActivate = true;
  };

  # - TRACKPAD - #
  system.defaults.trackpad = {
    Clicking = true; # enable tap to click
    Dragging = true;
    TrackpadRightClick = true; # enable two finger right click
    TrackpadThreeFingerDrag = false; # enable three finger drag
  };

  system.defaults.NSGlobalDomain = {
    "com.apple.trackpad.scaling" = 1.3; # pointer speed
  };

  # - KEYBOARD - #
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  system.defaults.NSGlobalDomain = {
    InitialKeyRepeat = 15;
    KeyRepeat = 2;

    # Use F1, F2 as standard function keys
    "com.apple.keyboard.fnState" = true;

    AppleKeyboardUIMode = 3; # 3 -> enable
    ApplePressAndHoldEnabled = false; # enable press and hold

    NSAutomaticCapitalizationEnabled = false; # disable auto capitalization
    NSAutomaticDashSubstitutionEnabled = false; # disable auto dash substitution
    NSAutomaticQuoteSubstitutionEnabled = false; # disable auto quote substitution
    NSAutomaticPeriodSubstitutionEnabled = false; # disable auto period substitution
    NSAutomaticSpellingCorrectionEnabled = false; # disable auto spelling correction
  };

  system.defaults.CustomUserPreferences."com.apple.HIToolbox" = {
    AppleFnUsageType = 0; # Do Nothing
    AppleCapsLockSwitchToLastInputSource = false;
  };

  system.activationScripts.userDefaults.text =
    # sh
    ''
      # Disable input source switch popup
      /usr/bin/defaults write kCFPreferencesAnyApplication TSMLanguageIndicatorEnabled 0

      # Disable dictation
      /usr/bin/defaults write \
        com.apple.HIToolbox \
        AppleDictationAutoEnable -bool false

      # Disable speech recognition
      /usr/bin/defaults write \
        com.apple.speech.recognition.AppleSpeechRecognition.prefs \
        DictationIMShortcut -string ""
      /usr/bin/defaults write \
        com.apple.speech.recognition.AppleSpeechRecognition.prefs \
        DictationIMMasterEnable -bool false
      /usr/bin/defaults write \
        com.apple.speech.recognition.AppleSpeechRecognition.prefs \
        DictationEnabled -bool false
    '';

  system.defaults.CustomUserPreferences."com.apple.symbolichotkeys" = {
    AppleSymbolicHotKeys = {
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

      "79" = {
        description = "Move left a Space (⌃ + ←)";
        enabled = false;
      };

      "80" = {
        description = "Move right a Space (⌃ + →)";
        enabled = false;
      };

      "81" = {
        description = "Mission Control – Show Dashboard";
        enabled = false;
      };

      "82" = {
        description = "Mission Control – Notification Center";
        enabled = false;
      };
    }
    // lib.genAttrs (builtins.genList (i: builtins.toString (i + 118)) 10) (
      name:
      let
        seq = lib.strings.toInt name - 118 + 1;
      in
      {
        enabled = false;
        description = "Disable move to space ${builtins.toString seq}";
      }
    );
  };

  # - MISC - #
  system.defaults.menuExtraClock.Show24Hour = true;
  system.defaults.menuExtraClock.ShowAMPM = false;
  system.defaults.NSGlobalDomain.AppleICUForce24HourTime = true;

  system.nvram.variables = {
    "StartupMute" = "%01"; # Disable boot sound
  };

  system.defaults.NSGlobalDomain = {
    # disable beep sound on volume up/down
    "com.apple.sound.beep.feedback" = 0;
    "com.apple.sound.beep.volume" = 0.000;
  };

  system.defaults.screencapture = {
    type = "png";
    location = "~/Desktop";
  };

  system.defaults.CustomSystemPreferences = {
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
  };
}
