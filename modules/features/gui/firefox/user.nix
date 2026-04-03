{
  pkgs,
  lib,
  ...
}:
{
  programs.firefox = {
    enable = true;
    package = lib.mkIf pkgs.stdenv.isDarwin null;

    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;
      settings = {
        "browser.toolbars.bookmarks.visibility" = "always";
        "browser.translations.automaticallyPopup" = false;
        "browser.warnOnQuitShortcut" = false;
        "browser.warnOnQuit" = false;
        "browser.tabs.firefox-view" = false;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "services.sync.prefs.sync.browser.uiCustomization.state" = true;
        "ui.key.menuAccessKeyFocuses" = false;
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

    profiles.proxy = {
      id = 1;
      name = "proxy";
      isDefault = false;
      settings = {
        "browser.toolbars.bookmarks.visibility" = "always";
        "browser.translations.automaticallyPopup" = false;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "services.sync.prefs.sync.browser.uiCustomization.state" = true;
        "sidebar.revamp" = false;

        "network.proxy.type" = 1;
        "network.proxy.http" = "127.0.0.1";
        "network.proxy.http_port" = 8080;
        # "network.proxy.ssl" = "127.0.0.1";
        # "network.proxy.ssl_port" = 8080;
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
