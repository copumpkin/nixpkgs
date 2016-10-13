{ stdenv, fetchFromGitHub, automake, autoconf, pkgconfig, libcap }:

stdenv.mkDerivation rec {
  name = "bubblewrap-${rev}";
  rev  = "0.1.2";

  src = fetchFromGitHub {
    inherit rev;
    owner  = "projectatomic";
    repo   = "bubblewrap";
    sha256 = "006myx7bqafglwh1s5121bb90kr2cnsfnqzlr6b9x83ddda1wf6g";
  };

  buildInputs = [ automake autoconf pkgconfig libcap ];

  preConfigure = "./autogen.sh";
}
