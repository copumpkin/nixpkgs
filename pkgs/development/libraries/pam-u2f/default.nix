{ stdenv, fetchurl, pkgconfig, openpam, libu2f-host, libu2f-server, IOKit }:

stdenv.mkDerivation rec {
  name = "pam_u2f-0.0.1";

  src = fetchurl {
    url    = "https://developers.yubico.com/pam-u2f/Releases/${name}.tar.gz";
    sha256 = "0p1wia4nfw5h0pmy1lcgwsbrlm7z39v1n37692lgqfzyg1kmpv7l";
  };

  patches = [ ./errno.patch ];

  postPatch = ''
    substituteInPlace ./configure \
      --replace "/lib/x86_64-linux-gnu/security" "$out/lib/security"
  '';

  buildInputs = [ pkgconfig openpam libu2f-host libu2f-server ] ++ stdenv.lib.optional stdenv.isDarwin IOKit;
}