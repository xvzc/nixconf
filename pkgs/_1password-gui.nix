{ stdenv }:
# Since `_1password-gui` for darwin is marked as broken,
#   we replace this with a dummy data so that we can keep `_1password-gui` as a shared package.
# On macOS instead, 1Password will be installed via Homebrew.
# See also https://github.com/NixOS/nixpkgs/issues/254944
stdenv.mkDerivation {
  pname = "_1password-gui";
  version = "0.0.0";
  src = null;

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out
  '';
}
