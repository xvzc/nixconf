{
  lib,
  pkgs,
  ctx,
  ...
}:
{
  home-manager.users.${ctx.user} =
    { ... }:
    {
      programs.fd = {
        enable = true;

        extraOptions = [
          # "--absolute-path"
          "--hidden"
        ];

        ignores = (
          [
            ".cache"
            ".config/Slack"
            ".config/google-chrome"
            ".git"
            ".github"
            ".local/"
            ".nix-defexpr/"
            ".nix-profile/"
            ".npm"
            ".yarn/"
            ".zsh_sessions/"

            "go/"
            "node_modules/"

            "*.otf"
            "*.pdf"
            "*.ttf"
            "*.woff"
            "*.woff2"
          ]
          ++ lib.optionals pkgs.stdenv.isDarwin [
            ".config/raycast"
            ".DS_Store"
            ".terminfo"
            ".Trash/"

            "Applications"
            "Library"
            "Movies"
            "Music"
            "Pictures"
            "Public"
          ]
          ++ lib.optionals pkgs.stdenv.isLinux [
            ".fontconfig"
            ".PlayOnLinux/"
            ".wine"

            "/boot/"
            "/dev/"
            "/lib/"
            "/lib32/"
            "/proc/"
            "/run/"
            "/sys/"
          ]
        );
      };
    };
}
