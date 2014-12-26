{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  version = "55471.14.18";
  name    = "Security-${version}";

  src = fetchurl {
    url    = "http://www.opensource.apple.com/tarballs/Security/${name}.tar.gz";
    sha256 = "1nv0dczf67dhk17hscx52izgdcyacgyy12ag0jh6nl5hmfzsn8yy";
  };

  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    ###### IMPURITIES
    mkdir -p $out/Library/Frameworks/Security.framework
    pushd $out/Library/Frameworks/Security.framework
    ln -s /System/Library/Frameworks/Security.framework/Security
    ln -s /System/Library/Frameworks/Security.framework/Resources
    ln -s /System/Library/Frameworks/Security.framework/PlugIns
    ln -s /System/Library/Frameworks/Security.framework/XPCServices
    popd

    ###### HEADERS

    export dest=$out/Library/Frameworks/Security.framework/Headers
    mkdir -p $dest
    cp sec/Security/*.h                  $dest
    cp libsecurity_authorization/lib/*.h $dest
    cp libsecurity_cssm/lib/*.h          $dest

    # For some reason most of the subincludes are omitted. TODO: add the others
    cat <<EOF >> $dest/Security.h
    #include <Security/Authorization.h>
    #include <Security/AuthorizationTags.h>
    #include <Security/AuthorizationDB.h>
    EOF
  '';
}
