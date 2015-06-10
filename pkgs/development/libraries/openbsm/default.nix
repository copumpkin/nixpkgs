{ stdenv, fetchurl, bootstrap_cmds }:

stdenv.mkDerivation {
  name = "openbsm-1.1p2";

  src = fetchurl {
    url    = "http://www.trustedbsd.org/downloads/openbsm-1.1-p2.tgz";
    sha256 = "1cwyxvl9mpssnfkq6cjblc2ssa91s2ar5zz9g1n6mfvfs0kmlf7k";
  };

  buildInputs = stdenv.lib.optional stdenv.isDarwin bootstrap_cmds;

  patchPhase = ''
    substituteInPlace ./configure \
      --replace "/usr/include/" "${stdenv.cc.libc}/include/"
  '';

  meta = with stdenv.lib; {
    description = "A portable implementation of Sun's Basic Security Module (BSM) security audit API and file format";
    license     = licenses.bsd2;
    platforms   = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ copumpkin ];
  };
}
