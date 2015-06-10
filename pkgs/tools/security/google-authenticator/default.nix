{ stdenv, fetchurl, pam, qrencode }:

stdenv.mkDerivation rec {
  name = "google-authenticator-1.0";

  src = fetchurl {
    url  = "https://google-authenticator.googlecode.com/files/libpam-${name}-source.tar.bz2";
    sha1 = "017b7d89989f1624e360abe02d6b27a6298d285d";
  };

  buildInputs = [ pam ];

  preConfigure = if stdenv.isDarwin then ''
    sed -i 's|libqrencode.so.2|${qrencode}/lib/libqrencode.dylib|' google-authenticator.c
    substituteInPlace Makefile --replace ".so" ".dylib"
    substituteInPlace pam_google_authenticator_unittest.c \
      --replace "pam_google_authenticator_testing.so" "pam_google_authenticator_testing.dylib"
  '' else ''
    sed -i 's|libqrencode.so.3|${qrencode}/lib/libqrencode.so.3|' google-authenticator.c
  '';

  installPhase = ''
    mkdir -p $out/bin $out/lib/security
    cp pam_google_authenticator.${if stdenv.isDarwin then "dylib" else "so"} $out/lib/security
    cp google-authenticator $out/bin
  '';

  doCheck     = !stdenv.isDarwin;
  checkTarget = "test";

  meta = {
    homepage = https://code.google.com/p/google-authenticator/;
    description = "Two-step verification, with pam module";
    license = stdenv.lib.licenses.asl20;
  };
}
