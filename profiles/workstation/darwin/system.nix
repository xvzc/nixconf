{
  pkgs,
  lib,
  ctx,
  ...
}:
{
  # Disable pre-defined nix-darwin modules to override.
  disabledModules = [
    "services/yabai"
    "programs/_1password-gui"
    "programs/_1password"
  ];

  imports = [
    ../../../modules/system/darwin/programs/_1password-gui.nix
    ../../../modules/system/darwin/programs/_1password.nix

    ../../../modules/system/darwin/services/yabai.nix
  ];

  services.yabai.enable = true;

  # ┌──────────┐
  # │ SECURITY │
  # └──────────┘
  environment.systemPackages = [
    pkgs.pam-reattach
  ];

  security.pam.enableSudoTouchIdAuth = true;

  # Enable touch id authentication in tmux sessions.
  environment.etc."pam.d/sudo_local".text = ''
    auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so
    auth       sufficient     pam_tid.so
  '';
  # - SECURITY - 8<

  # ┌──────────┐
  # │ HOMEBREW │
  # └──────────┘
  environment.systemPath = [
    "/opt/homebrew/bin"
  ];

  nix-homebrew = {
    enable = true;
    user = ctx.user;
    enableRosetta = false;
    # mutableTaps = true; # disable `brew tap <name>`
  };

  homebrew = {
    enable = true;

    casks = [
      "docker"
      "chatgpt"
    ];

    masApps = {
      "KakaoTalk" = 869223134;
    };
  };
  # - HOMEBREW - 8<

  # ┌─────────────────┐
  # │ SYSTEM_SETTINGS │
  # └─────────────────┘
  # ===================
  system.stateVersion = 5;

  system.defaults.loginwindow = {
    autoLoginUser = ctx.user;
    SHOWFULLNAME = false; # show full name in login window
    GuestEnabled = false; # disable guest user
  };

  # ┌──────┐
  # │ DOCK │
  # └──────┘
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
  # - DOCK - 8<

  # ┌────────┐
  # │ FINDER │
  # └────────┘
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
  # - FINDER - 8<

  # ┌─────────┐
  # │ DISPLAY │
  # └─────────┘
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
  # - DISPLAY - 8<

  # ┌──────────┐
  # │ TRACKPAD │
  # └──────────┘
  system.defaults.trackpad = {
    Clicking = true; # enable tap to click
    Dragging = true;
    TrackpadRightClick = true; # enable two finger right click
    TrackpadThreeFingerDrag = false; # enable three finger drag
  };

  system.defaults.NSGlobalDomain = {
    "com.apple.trackpad.scaling" = 1.3; # pointer speed
  };
  # - TRACKPAD - 8<

  # ┌──────────┐
  # │ KEYBOARD │
  # └──────────┘
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

  system.activationScripts.userDefaults.text = # sh
    ''
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

      "118" = {
        description = "Trigger Spotlight finder search";
        enabled = true;
        value = {
          type = "standard";
          parameters = [
            65535
            18
            262144
          ];
        };
      };
    };
  };
  # - KEYBOARD - 8<

  # ┌──────┐
  # │ MISC │
  # └──────┘
  system.defaults.menuExtraClock.Show24Hour = true;
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
  # - MISC - 8<
  # = SYSTEM_SETTINGS = 8<
}
