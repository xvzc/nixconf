{
  lib,
  stdenv,
  fetchurl,
  unzip,
  undmg,
  ...
}:
let
  pname = "Firefox web browser";
  version = "145.0.2";

  message = {
    notSupported = "${stdenv.hostPlatform.system} is not supported";
  };

  srcs =
    let
      baseUrl = "https://archive.mozilla.org/pub/firefox/releases";
    in
    {
      aarch64-darwin = fetchurl {
        url = "${baseUrl}/${version}/mac/en-US/Firefox%20${version}.dmg";
        sha256 = "sha256-gPWFH5DeiNG40nKZywo/87n/N3TCdd4mdfZRg0vZIos=";
      };
    };
  meta = {
    description = "Firefox browser";
  };
in
stdenv.mkDerivation {
  inherit pname version meta;

  src = srcs.${stdenv.hostPlatform.system} or (throw message.notSupported);
  nativeBuildInputs = [
    unzip
    undmg
  ];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
  '';

  dontFixup = true;
}
