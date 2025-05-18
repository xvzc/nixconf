{ stdenv, fetchurl }:
let
  baseurl = "https://raw.githubusercontent.com";
  message = {
    notSupported = "${stdenv.hostPlatform.system} is not supported";
  };
  srcs = {
    aarch64-darwin = fetchurl {
      url = "${baseurl}/daipeihust/im-select/master/macOS/out/apple/im-select";
      sha256 = "sha256-MbBlL421nvBpBs1qhjXcweYWKILoMAytSCqLW5f/8pA=";
    };
  };
in
(stdenv.mkDerivation {
  pname = "im-select";
  version = "0.0";

  src = srcs.${stdenv.hostPlatform.system} or (throw message.notSupported);

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin

    cp $src $out/bin/im-select
    chmod +x $out/bin/im-select
  '';
})
