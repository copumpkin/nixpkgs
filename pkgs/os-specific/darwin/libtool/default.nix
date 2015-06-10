{ stdenv, cctools, libtool, m4, makeWrapper }:

stdenv.mkDerivation {
  name = "libtool-darwin-862";

  buildInputs = [ makeWrapper ];

  buildCommand = ''
    mkdir -p $out/bin
    ln -s ${cctools}/bin/libtool $out/bin/libtool
    ln -s ${libtool}/bin/libtoolize $out/bin
    wrapProgram $out/bin/libtoolize --prefix PATH : ${m4}/bin
  '';
}
