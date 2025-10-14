# default.nix
{ stdenv, ... }:

stdenv.mkDerivation {
  pname = "empty-package";
  version = "0.1";

  phases = [ "installPhase" ];

  # The installPhase is where you define how to "install" your package.
  # For an empty package, we can simply do nothing or create an empty directory.
  installPhase = ''
    mkdir -p $out/bin
    # Optionally, you can create a dummy file if you need some output
    echo "This is an empty package." > $out/bin/dummy-file
  '';
}
