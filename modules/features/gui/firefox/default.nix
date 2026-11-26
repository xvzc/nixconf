{
  ctx,
  lib,
  pkgs,
  ...
}:
lib.optionalAttrs ctx.isDarwin {
  # Mozilla's signed app, unpacked as is (1Password's browser integration
  # rejects an unsigned or re-wrapped Firefox). Not programs.firefox.package:
  # Home Manager would wrap it, which breaks the signature there.
  environment.systemPackages = [ pkgs.mv.tip.firefox-bin-unwrapped ];
}
// {
  # ┌────────┐
  # │ COMMON │
  # └────────┘
  nixpkgs.overlays = lib.mkBefore [
    (final: prev: {
      firefox = final.mv.tip.firefox-unwrapped;
    })
  ];

  hm.users.default =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      # Firefox rewrites profiles.ini itself; replace it on activation instead
      # of stopping at the conflict.
      home.file."${config.programs.firefox.configPath}/profiles.ini".force = true;

      # Linux: move the profiles from the legacy ~/.mozilla/firefox to the XDG
      # path, once, before the new files are linked. Not while Firefox runs.
      home.activation.firefoxXdgProfiles = lib.mkIf pkgs.stdenv.isLinux (
        lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
          old="$HOME/.mozilla/firefox"
          new="${config.programs.firefox.configPath}"
          if [ -d "$old" ] && [ ! -L "$old" ] && [ ! -e "$new" ]; then
            if ${pkgs.procps}/bin/pgrep -u "$(id -u)" -f '(^|/)\.?firefox(-bin)?(-wrapped)?( |$)' >/dev/null; then
              errorEcho "Firefox is running: quit it, so $old can move to $new."
              exit 1
            fi
            run mkdir -p "$(dirname "$new")"
            run mv $VERBOSE_ARG "$old" "$new"
          elif [ -d "$old" ] && [ ! -L "$old" ]; then
            warnEcho "Both $old and $new exist; Firefox uses $new. Remove $old once unneeded."
          fi
        ''
      );

      programs.firefox = {
        enable = true;
        # No built-in VPN (IP Protection), nor its toolbar button. A policy, so
        # Mozilla's remote rollouts (Nimbus) cannot turn it back on.
        policies = {
          IPProtectionAvailable = false;
          # Versions come from Nix; the app cannot update itself in the store.
          DisableAppUpdate = true;
        };
        # Linux: the XDG path, Home Manager's default from 26.05 (set here, as
        # home.stateVersion is older). Darwin keeps its own default, the only
        # place Firefox reads there.
        configPath = lib.mkIf pkgs.stdenv.isLinux "${config.xdg.configHome}/mozilla/firefox";
        # Darwin: installed above, unwrapped; policies go to macOS defaults.
        package = if pkgs.stdenv.isDarwin then null else pkgs.firefox-bin;

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
            .browserContainer > findbar {
              order:-1 !important; /*113*/
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
