{ stdenv, fetchFromGitHub, python, ninja, libpthread }:

let
  libpthread-ours = libpthread.overrideDerivation (args: {
    installPhase = ''
      mkdir -p $out/include/
      cp -r pthread $out/include
      cp -r sys $out/include
  '';
  });
in stdenv.mkDerivation rec {
  name = "CoreFoundation";
  rev  = "57ffb9d452995d66830965b78bb4ea16d19c3f47";
  src  = fetchFromGitHub {
    inherit rev;
    owner  = "apple";
    repo   = "swift-corelibs-foundation";
    sha256 = "1igd4fff1mx0s1rgzl25y93l1a1573dmhnygrqjz3f8v42aqsh4y";
  };

  buildInputs = [ python ninja libpthread-ours ];

  configurePhase = ''
    DSTROOT=$out
    export CFLAGS="-D__AVAILABILITY_INTERNAL__MAC_10_10 -D__MAC_10_10=101000 -D__IPHONE_8_0=80000"
    ./configure --sysroot ignored
  '';

  buildPhase = ''
    ninja
  '';
}
