{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  version = "20140912";
  name    = "openpam-${version}";

  src = fetchurl {
    url    = "http://downloads.sourceforge.net/project/openpam/openpam/Ourouparia/${name}.tar.gz";
    sha256 = "11xw889dy35iz43ydywz3lsd9ax9vbzhm3k18aby9356gwwjkg42";
  };

  meta.platforms = stdenv.lib.platforms.all;
}
