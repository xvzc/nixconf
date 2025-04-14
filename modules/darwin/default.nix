{
  inputs,
  pkgs,
  curEnv,
  lib,
  config,
  ...
}:
let
  sharedFonts = import ../_shared/fonts.nix { inherit pkgs; };
  sharedPrograms = import ../_shared/programs.nix;
  sharedPkgs = import ../_shared/pkgs.nix {
    inherit pkgs lib curEnv;
  };
  # sharedFiles = import ../_shared/files.nix {
  #   inherit config;
  # };
in
{
  imports = [
    # sharedFiles
    ./settings.nix
    # ./homebrew.nix
  ];

  users.users.${curEnv.user} = {
    name = "${curEnv.user}";
    home = "/Users/${curEnv.user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.${curEnv.user} =
      {
        pkgs,
        ...
      }:
      {
        home = {
          stateVersion = "24.11";
          enableNixpkgsReleaseCheck = false;
          packages = sharedPkgs ++ [ ];
        };

        programs = { } // sharedPrograms;

        manual.manpages.enable = true;
      };
  };

  # Fonts
  fonts = {
    packages = sharedFonts;
  };
}
