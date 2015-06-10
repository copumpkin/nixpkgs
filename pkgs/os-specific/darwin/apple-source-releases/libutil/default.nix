{ stdenv, appleDerivation }:

appleDerivation {
  phases = [ "unpackPhase" "buildPhase" "installPhase" ];

  buildPhase = ''
    cc  -I . -c pidfile.c
    cc  -I . -c humanize_number.c
    cc  -I . -c getmntopts.c
    cc  -I . -c realhostname.c
    cc  -I . -c reexec_to_match_kernel.c
    cc  -I . -c trimdomain.c
    c++ -I . -c wipefs.cpp
    c++ -I . -c ExtentManager.cpp

    c++ -dynamiclib -install_name $out/lib/libutil.dylib *.o -o libutil.dylib
  '';

  installPhase = ''
    mkdir -p $out/lib $out/include
    cp libutil.dylib $out/lib
    cp mntopts.h libutil.h wipefs.h $out/include
  '';
}