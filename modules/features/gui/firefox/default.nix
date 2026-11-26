{
  ctx,
  lib,
  pkgs,
  ...
}:
let
  # Mozilla's own builds from multiverse, so both OSes run the same version.
  # Darwin: the signed app unpacked as is (1Password's browser integration
  # rejects an unsigned or re-wrapped Firefox), installed system-wide, not as
  # programs.firefox.package: Home Manager would wrap it and break the
  # signature. Linux: the wrapped one, which takes the policies.
  firefox = if ctx.isDarwin then pkgs.mv.tip.firefox-bin-unwrapped else pkgs.mv.tip.firefox-bin;
in
lib.optionalAttrs ctx.isDarwin {
  environment.systemPackages = [ firefox ];
}
// {
  hm.users.default =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      # Extensions, by add-on ID: their addons.mozilla.org slug.
      extensions = {
        "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = "vimium-ff";
        "{d634138d-c276-4fc8-924b-40a0ea21d284}" = "1password-x-password-manager";
      };
    in
    {
      # Firefox rewrites profiles.ini itself; replace it on activation instead
      # of stopping at the conflict.
      home.file."${config.programs.firefox.configPath}/profiles.ini".force = true;

      programs.firefox = {
        enable = true;
        # No built-in VPN (IP Protection), nor its toolbar button. A policy, so
        # Mozilla's remote rollouts (Nimbus) cannot turn it back on.
        policies = {
          IPProtectionAvailable = false;
          # Versions come from Nix; the app cannot update itself in the store.
          DisableAppUpdate = true;
          # Installed from addons.mozilla.org, latest version, in every
          # profile; their buttons go in the extensions menu, not the toolbar.
          ExtensionSettings = lib.mapAttrs (_: slug: {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
            default_area = "menupanel";
          }) extensions;
        };
        # Darwin: installed above; policies go to macOS defaults.
        package = if ctx.isDarwin then null else firefox;

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
            /* Find bar above the page, full width. The content area is a grid
               now, so `order` alone no longer moves it: take the cell of the
               notification box (above the page), and draw over a notification
               that shares it. */
            findbar {
              grid-area: notificationbox !important;
              order: -1 !important;
              position: relative;
              z-index: 1;
              border-top: none !important;
              border-bottom: 1px solid ThreeDShadow !important;
            }

            /* No bookmarks sidebar (the bookmarks toolbar stays). */
            #sidebar-box[sidebarcommand="viewBookmarksSidebar"],
            #sidebar-box[sidebarcommand="viewBookmarksSidebar"] + #sidebar-splitter {
              display: none !important;
            }

            /* No sidebar button in the toolbar. */
            #sidebar-button {
              display: none !important;
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
            /* Find bar above the page, full width. The content area is a grid
               now, so `order` alone no longer moves it: take the cell of the
               notification box (above the page), and draw over a notification
               that shares it. */
            findbar {
              grid-area: notificationbox !important;
              order: -1 !important;
              position: relative;
              z-index: 1;
              border-top: none !important;
              border-bottom: 1px solid ThreeDShadow !important;
            }

            /* No bookmarks sidebar (the bookmarks toolbar stays). */
            #sidebar-box[sidebarcommand="viewBookmarksSidebar"],
            #sidebar-box[sidebarcommand="viewBookmarksSidebar"] + #sidebar-splitter {
              display: none !important;
            }

            /* No sidebar button in the toolbar. */
            #sidebar-button {
              display: none !important;
            }
          '';
        };
      };
    };
}
