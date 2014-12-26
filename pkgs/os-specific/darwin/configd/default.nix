{ stdenv, fetchurl, launchd, Security }:

stdenv.mkDerivation rec {
  version = "596.15";
  name    = "configd-${version}";

  src = fetchurl {
    url    = "http://www.opensource.apple.com/tarballs/configd/${name}.tar.gz";
    sha256 = "01zgmbk67lwl3xg41pn2ykrs3va2drwjicbvfa49kpmwzf8saf2x";
  };

  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

  buildInputs = [ launchd ];

  propagatedBuildInputs = [ Security ];

  installPhase = ''
    mkdir -p $out/include
    cp dnsinfo/*.h $out/include/

    ###### IMPURITIES

    mkdir -p $out/Library/Frameworks/SystemConfiguration.framework
    pushd $out/Library/Frameworks/SystemConfiguration.framework
    ln -s /System/Library/Frameworks/SystemConfiguration.framework/Versions/A/SystemConfiguration
    ln -s /System/Library/Frameworks/SystemConfiguration.framework/Versions/A/Resources
    popd

    ###### HEADERS

    mkdir -p $out/Library/Frameworks/SystemConfiguration.framework/Headers
    cp SystemConfiguration.fproj/*.h $out/Library/Frameworks/SystemConfiguration.framework/Headers/
  '';
}
