{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  version = "551.1";
  name    = "objc4-${version}";

  src = fetchurl {
    url    = "http://www.opensource.apple.com/tarballs/objc4/${name}.tar.gz";
    sha256 = "1jrdb6yyb5jwwj27c1r0nr2y2ihqjln8ynj61mpkvp144c1cm5bg";
  };

  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    mkdir -p $out/include/objc $out/lib
    ln -s /usr/lib/libobjc.dylib $out/lib/libobjc.dylib
    cp runtime/OldClasses.subproj/List.h $out/include/objc/List.h
    cp runtime/NSObjcRuntime.h $out/include/objc/NSObjcRuntime.h
    cp runtime/NSObject.h $out/include/objc/NSObject.h
    cp runtime/Protocol.h $out/include/objc/Protocol.h
    cp runtime/hashtable.h $out/include/objc/hashtable.h
    cp runtime/hashtable2.h $out/include/objc/hashtable2.h
    cp runtime/message.h $out/include/objc/message.h
    cp runtime/objc-api.h $out/include/objc/objc-api.h
    cp runtime/objc-auto.h $out/include/objc/objc-auto.h
    cp runtime/objc-class.h $out/include/objc/objc-class.h
    cp runtime/objc-exception.h $out/include/objc/objc-exception.h
    cp runtime/objc-load.h $out/include/objc/objc-load.h
    cp runtime/objc-runtime.h $out/include/objc/objc-runtime.h
    cp runtime/objc-sync.h $out/include/objc/objc-sync.h
    cp runtime/objc.h $out/include/objc/objc.h
    cp runtime/runtime.h $out/include/objc/runtime.h
  '';
}
