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
    find -name \*.otf \
      -exec mkdir -p $out/share/fonts/opentype/Nanum \; \
      -exec mv {} $out/share/fonts/opentype/Nanum \;

    find -name \*.ttf \
      -exec mkdir -p $out/share/fonts/truetype/Nanum \; \
      -exec mv {} $out/share/fonts/truetype/Nanum \;
  '';
})
