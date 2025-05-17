lib:
{ ... }@args:
rec {
  inherit (args) system user host;
  isDarwin = builtins.elem args.system lib.platforms.darwin;
  isLinux = builtins.elem args.system lib.platforms.linux;
  os = if isDarwin then "darwin" else "linux";
}
