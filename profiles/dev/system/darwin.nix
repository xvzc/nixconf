{
  ctx,
  lib,
  pkgs,
  ...
}@args:
let
  wallpaper = "/Users/${ctx.username}/nixfiles/.assets/wallpaper.jpeg";
in
assert builtins.pathExists ../../../.assets/wallpaper.jpeg;
{
  imports = [ ./base.nix ];

  # Unlike `nixos`, `nix-darwin` requires `system.stateVersion` to be an int.
  # So we set this option separately based on the current platform.
  system.stateVersion = 5;

  # The user should already exist, but we need to set
  # this up so Nix knows what our home directory is.
  # https://github.com/LnL7/nix-darwin/issues/423
  users = {
    knownUsers = [ "${ctx.username}" ];
    users.${ctx.username} = {
      uid = 501; # This is the default user id for darwin system
      home = "/Users/${ctx.username}";
      shell = pkgs.zsh;
    };
  };

  environment.systemPackages = with pkgs; [
    pam-reattach
  ];

  nix-homebrew = {
    enable = true;
    user = "${ctx.username}";
    enableRosetta = false;
    mutableTaps = true; # disable `brew tap <name>`
  };

  homebrew = {
    enable = true;
    taps = [
      "daipeihust/tap" # im-select
    ];

    brews = [
      "im-select"
    ];

    casks = [
      "raycast"
      "chatgpt"
      "1password"
      "wezterm"
    ];

    masApps = {
      "KakaoTalk" = 869223134;
    };
  };

  services = {
    yabai = import ./services/yabai.nix args;
    skhd = import ./services/skhd.nix args;
  };

  # ┌────────────────────┐
  # │ System Preferences │
  # └────────────────────┘
  security.pam.enableSudoTouchIdAuth = true;

  # Enable touch id authentication in tmux sessions.
  environment.etc."pam.d/sudo_local".text = ''
    auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so
    auth       sufficient     pam_tid.so
  '';

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
    nonUS.remapTilde = false; # This doesn't work in Korean keyboard
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

      # Set wallpaper
      osascript \
        -e 'tell application "Finder"' \
        -e '  set desktop picture to POSIX file "${wallpaper}"' \
        -e 'end tell';
    '';

  system.activationScripts.postUserActivation.text = # sh
    ''
      # Restart `yabai` and `skhd`
      sudo launchctl kickstart -k system/org.nixos.yabai-sa || true
      launchctl kickstart -k "gui/$(id -u)/org.nixos.yabai" || true
      launchctl kickstart -k "gui/$(id -u)/org.nixos.skhd" || true
    '';

  system.nvram.variables = {
    "StartupMute" = "%01"; # Disable boot sound
    "boot-args" = "-arm64e_preview_abi"; # Allow non-Apple signed binaries
  };

  system.defaults.menuExtraClock.Show24Hour = true;
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

    persistent-apps = [
      "/Applications/WezTerm.app"
      "${pkgs.google-chrome}/Applications/Google Chrome.app"
      "${pkgs.spotify}/Applications/Spotify.app"
    ];

    # Disable all hot corners
    wvous-bl-corner = 1;
    wvous-br-corner = 1;
    wvous-tl-corner = 1;
    wvous-tr-corner = 1;
  };

  system.defaults.finder = {
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

  system.defaults.trackpad = {
    Clicking = true; # enable tap to click
    Dragging = true;
    TrackpadRightClick = true; # enable two finger right click
    TrackpadThreeFingerDrag = false; # enable three finger drag
  };

  system.defaults.NSGlobalDomain = {
    # `defaults read NSGlobalDomain "xxx"`
    "com.apple.keyboard.fnState" = true;
    "com.apple.sound.beep.feedback" = 0; # disable beep sound on volume up/down
    "com.apple.swipescrolldirection" = true; # enable natural scrolling(default to true)
    "com.apple.trackpad.scaling" = 1.3;

    AppleInterfaceStyle = "Dark"; # dark mode

    AppleKeyboardUIMode = 3; # Mode 3 enables full keyboard control.
    ApplePressAndHoldEnabled = false; # enable press and hold

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

  system.defaults.spaces = {
    # Display have separate spaces
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

  system.defaults.screencapture = {
    type = "png";
    location = "~/Desktop";
  };

  system.defaults.loginwindow = {
    SHOWFULLNAME = false; # show full name in login window
    GuestEnabled = false; # disable guest user
    autoLoginUser = ctx.username;
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

  system.defaults.CustomUserPreferences."com.apple.HIToolbox" = {
    AppleFnUsageType = 0;
    AppleCapsLockSwitchToLastInputSource = false;
  };

  system.defaults.CustomUserPreferences."com.apple.symbolichotkeys".AppleSymbolicHotKeys = {
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
}
