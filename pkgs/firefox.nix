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
  version = "144.0";

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
        sha256 = "sha256-HkRLgJIbyZnVbAWn3swer4jAKXysW5BBYpmvLHf17Mk=";
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
