{env, ...}: {
  useGlobalPkgs = true;
  useUserPackages = true;
  backupFileExtension = "hm-bak";

  users.${env.user} = {
    pkgs,
    config,
    ...
  }: let
    utils = import ../../../lib/utils.nix;
    files = import ./files.nix {inherit config;};
    programArgs = {inherit config pkgs;};
  in {
    imports = [../../_shared/home/dotfiles.nix];

    home.stateVersion = "24.11";
    home.activation.setup1Password = import ../assets/setup-1password.nix {};

    home.packages = pkgs.callPackage ./pkgs.nix {};

    home.file = files.home;
    xdg.configFile = files.xdg;

    programs =
      utils.importAttrSetsFromDir ../../_shared/home/programs programArgs
      // utils.importAttrSetsFromDir ./programs programArgs;
  };
}
