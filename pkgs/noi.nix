{ stdenv, fetchurl }:
let
  # https://github.com/lencx/Noi/releases/download/v0.4.0/Noi-darwin-arm64-0.4.0.zip
  pname = "noi";
  version = "0.4.0";
  baseurl = "https://github.com/lencx/Noi/releases/download";

  message = {
    notSupported = "${stdenv.hostPlatform.system} is not supported";
  };

  srcs = {
    aarch64-darwin = fetchurl {
      url = "${baseurl}/v${version}/Noi-darwin-arm64-0.4.0.zip";
      sha256 = "sha256-MbBlL421nvBpBs1qhjXcweYWKILoMAytSCqLW5f/8pA=";
    };

    x86_64-linux = fetchurl {
      url = "${baseurl}/v${version}/Noi-darwin-arm64-0.4.0.zip";
      sha256 = "sha256-MbBlL421nvBpBs1qhjXcweYWKILoMAytSCqLW5f/8pA=";
    };
  };
in
(stdenv.mkDerivation {
  inherit pname version;

  src = srcs.${stdenv.hostPlatform.system} or (throw message.notSupported);

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin

    cp $src $out/bin/im-select
    chmod +x $out/bin/im-select
  '';
})
