{ lib, pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    # package = pkgs.firefox-bin;
    nativeMessagingHosts = [
      pkgs._1password-gui
      pkgs._1password
    ];

    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;
      settings = {
        "browser.toolbars.bookmarks.visibility" = "always";
        "browser.translations.automaticallyPopup" = false;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "services.sync.prefs.sync.browser.uiCustomization.state" = true;
        "sidebar.revamp" = false;
      };
      userChrome = ''
        .browserContainer > findbar {
          order:-1 !important; /*113*/
          border-top: none !important;
          border-bottom: 1px solid ThreeDShadow !important;
        }
      '';
    };
  };
}
