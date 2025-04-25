{ stdenv, fetchzip }:
(stdenv.mkDerivation {
  pname = "nanum-square-neo";
  version = "0.0";

  src = fetchzip {
    url = "https://hangeul.naver.com/hangeul_static/webfont/zips/nanum-square-neo.zip";
    sha256 = "slmrYlH+WmvJ7IsbM8+WWiokVmcvOOpuhfWOC8ih244=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp ./ttf/*.ttf $out/share/fonts/truetype || true
  '';
})
