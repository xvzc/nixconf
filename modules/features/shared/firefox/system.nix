{
  lib,
  pkgs,
  ctx,
  ...
}:
{
  # See, https://github.com/nix-darwin/nix-darwin/blob/master/modules/programs/_1password-gui.nix
  system.activationScripts.applications.text = lib.optionalString pkgs.stdenv.isDarwin (
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
}
