{ stdenv, fetchurl, libdispatch, xnu }:

stdenv.mkDerivation rec {
  version = "105.1.4";
  name    = "libpthread-${version}";

  src = fetchurl {
    url    = "http://opensource.apple.com/tarballs/libpthread/${name}.tar.gz";
    sha256 = "09vwwahcvmxvx2xl0890gkp91n61dld29j73y2pa597bqkag2qpg";
  };

  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

  propagatedBuildInputs = [ libdispatch xnu ];

  installPhase = ''
    mkdir -p $out/include/pthread
    cp pthread/*.h $out/include/pthread/
    cp private/*.h $out/include/pthread/
  '';
}
