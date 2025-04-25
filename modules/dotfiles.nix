{
  lib,
  config,
  ...
}: {
  options.dotfiles = lib.mkOption {
    type = lib.types.path;
    apply = toString;
    default = "${config.home.homeDirectory}/nixfiles/.dotfiles";
    description = "Location of the dotfiles";
  };
}
