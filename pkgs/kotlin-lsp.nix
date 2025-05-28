{
  pkgs,
  stdenv,
  fetchzip,
  makeWrapper,
  bash,
  jre ? pkgs.jre17_minimal,
}:
(stdenv.mkDerivation {
  pname = "kotlin-lsp";
  version = "0.252.17811";

  src = fetchzip {
    url = "https://download-cdn.jetbrains.com/kotlin-lsp/0.252.17811/kotlin-0.252.17811.zip";
    sha256 = "sha256-yplwz3SQzUIYaOoqkvPEy8nQ5p3U/e1O49WNxaE7p9Y=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    jre
  ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib

    cp $src/lib/* $out/lib
    cp $src/kotlin-lsp.sh $out/bin/kotlin-ls
    chmod +x $out/bin/kotlin-ls

    wrapProgram $out/bin/kotlin-ls \
      --add-flags "$@" \
      --set JAVA_HOME "${jre.home}"
  '';
})
