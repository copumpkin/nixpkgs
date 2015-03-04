{ stdenv, fetchurl, openssl, python, zlib, libuv, v8, utillinux, http-parser
, pkgconfig, runCommand, which, unstableVersion ? stdenv.isDarwin
, libtool, CoreServices, ApplicationServices
}:

let
  version = if unstableVersion then "0.11.15" else "0.12.0";

  deps = {
    inherit openssl zlib libuv;

    # disabled system v8 because v8 3.14 no longer receives security fixes
    # we fall back to nodejs' internal v8 copy which receives backports for now
    # inherit v8
  } // (stdenv.lib.optionalAttrs (!stdenv.isDarwin) {
    inherit http-parser;
  });

  sharedConfigureFlags = name: [
    "--shared-${name}"
    "--shared-${name}-includes=${builtins.getAttr name deps}/include"
    "--shared-${name}-libpath=${builtins.getAttr name deps}/lib"
  ];

  inherit (stdenv.lib) concatMap optional optionals maintainers licenses platforms;
in stdenv.mkDerivation {
  name = "nodejs-${version}";

  src = fetchurl {
    url = "http://nodejs.org/dist/v${version}/node-v${version}.tar.gz";
    sha256 = if unstableVersion
             then "008xk4866gr6mw2qavd6jds8gxrk2i4r5083302rmjd4p9sd44z6"
             else "0cifd2qhpyrbxx71a4hsagzk24qas8m5zvwcyhx69cz9yhxf404p";
  };

  configureFlags = concatMap sharedConfigureFlags (builtins.attrNames deps) ++ [ "--without-dtrace" ];

  prePatch = ''
    sed -e 's|^#!/usr/bin/env python$|#!${python}/bin/python|g' -i configure
  '';

  patches = if stdenv.isDarwin then [ ./no-xcode.patch ] else null;

  postPatch = if stdenv.isDarwin then ''
    (cd tools/gyp; patch -Np1 -i ${../../python-modules/gyp/no-darwin-cflags.patch})
  '' else null;

  preBuild = if stdenv.isDarwin then ''
    sed -e 's|^#!/usr/bin/env python$|#!${python}/bin/python|g' -i out/gyp-mac-tool
  '' else null;

  buildInputs = [ python which ]
    ++ (optional stdenv.isLinux utillinux)
    ++ optionals stdenv.isDarwin [ pkgconfig openssl libtool CoreServices ApplicationServices ];
  setupHook = ./setup-hook.sh;

  enableParallelBuilding = true;

  passthru.interpreterName = "nodejs";

  meta = {
    description = "Event-driven I/O framework for the V8 JavaScript engine";
    homepage = http://nodejs.org;
    license = licenses.mit;
    maintainers = [ maintainers.goibhniu maintainers.shlevy ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
