{config, ...}: let
  dotfiles = config.dotfiles;
  symlink = config.lib.file.mkOutOfStoreSymlink;
  sharedHomeFiles = import ../../_shared/home/files.nix {inherit config;};
in {
  home =
    sharedHomeFiles.home
    // {
      "Library/KeyBindings/DefaultKeyBinding.dict".text =
        builtins.readFile ../assets/DefaultKeyBinding.dict;
    };

  xdg =
    sharedHomeFiles.xdg
    // {
      "aerospace".source = symlink "${dotfiles}/.config/aerospace";
      "aerospace".recursive = true;
    };
}
