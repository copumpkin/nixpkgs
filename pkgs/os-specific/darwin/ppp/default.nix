{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  version = "727.90.1";
  name    = "ppp-${version}";

  src = fetchurl {
    url    = "http://www.opensource.apple.com/tarballs/ppp/${name}.tar.gz";
    sha256 = "166xz1q7al12hm3q3drlp2r6fgdrsq3pmazjp3nsqg3vnglyh4gk";
  };

  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

  installPhase = ''
    mkdir -p $out/include/ppp

    cp Controller/ppp_msg.h                    $out/include/ppp
    cp Controller/pppcontroller_types.h        $out/include/ppp
    cp Controller/pppcontroller_types.h        $out/include
    cp Controller/pppcontroller.defs           $out/include/ppp
    cp Controller/pppcontroller_mach_defines.h $out/include
    cp Controller/PPPControllerPriv.h          $out/include/ppp
  '';
}
