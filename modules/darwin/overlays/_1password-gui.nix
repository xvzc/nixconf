# Replace this with a dummy data so that we can keep 1Password as a shared package.
# On macOS instead, 1Password will be installed via Homebrew.
# See https://github.com/NixOS/nixpkgs/issues/254944
(final: prev: {
  _1password-gui = prev.stdenv.mkDerivation {
    pname = "_1password-gui";
    version = "0.0.0";
    src = null;

    dontUnpack = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out
    '';
  };
})
