{ stdenv, appleDerivation, libdispatch, xnu }:

appleDerivation {
  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

  propagatedBuildInputs = [ libdispatch xnu ];

  installPhase = ''
    mkdir -p $out/include/
    cp -r pthread $out/include
    cp -r sys $out/include
  '';
}
