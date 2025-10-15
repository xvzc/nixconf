{
  lib,
  pkgs,
  ctx,
  ...
}:
{
  # Based on https://github.com/reckenrode/nixos-configs/blob/22b8357fc6ffbd0df5ce50dc417c23a807a268a2/modules/by-name/1p/1password/darwin-module.nix
  # See Also, https://github.com/nix-darwin/nix-darwin/blob/master/modules/programs/_1password-gui.nix
  system.activationScripts.applications.text = lib.mkIf pkgs.stdenv.isDarwin (
    lib.mkAfter # sh
      ''
        install -o root -g wheel -m0555 -d "/Applications/Firefox.app"

        rsyncFlags=(
          --checksum
          --copy-unsafe-links
          --archive
          --delete
          --chmod=-w
          --no-group
          --no-owner
        )

        ${lib.getExe pkgs.rsync} "''${rsyncFlags[@]}" \
          ${pkgs.firefox}/Applications/Firefox.app/ /Applications/Firefox.app
      ''
  );

  home-manager.users.${ctx.user} =
    { ... }:
    {
      programs.firefox = {
        enable = true;
        package = lib.mkIf pkgs.stdenv.isDarwin null;
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
    };
}
