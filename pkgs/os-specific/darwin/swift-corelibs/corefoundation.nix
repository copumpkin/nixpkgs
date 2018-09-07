{ stdenv, fetchFromGitHub, fetchurl, python, ninja, libxml2, objc4, ICU, curl }:

let
  # 10.12 adds a new sysdir.h that our version of CF in the main derivation depends on, but
  # isn't available publicly, so instead we grab an older version of the same file that did
  # not use sysdir.h, but provided the same functionality. Luckily it's simple :) hack hack
  sysdir-free-system-directories = fetchurl {
    url    = "https://raw.githubusercontent.com/apple/swift-corelibs-foundation/9a5d8420f7793e63a8d5ec1ede516c4ebec939f0/CoreFoundation/Base.subproj/CFSystemDirectories.c";
    sha256 = "0krfyghj4f096arvvpf884ra5czqlmbrgf8yyc0b3avqmb613pcc";
  };
in stdenv.mkDerivation {
  name = "swift-corefoundation";

  src = fetchFromGitHub {
    owner  = "apple";
    repo   = "swift-corelibs-foundation";
    rev    = "a61b058ed53b00621e7acba4c53959e3ae01a254";
    sha256 = "06nqdic9pmizpf3f2gakq4i6ckqr2l6cxpw9g5bgi7qdivchvz8l";
  };

  buildInputs = [ ninja python libxml2 objc4 ICU curl ];

  patchPhase = ''
    cp ${sysdir-free-system-directories} CoreFoundation/Base.subproj/CFSystemDirectories.c

    # In order, since I can't comment individual lines:
    # 1. libxml path fix
    # 2. They seem to assume we include objc in some places and not in others, make a PR
    # 3. Disable dispatch support for now
    # 4. For the linker too
    # 5. They just forgot these, make a PR
    substituteInPlace CoreFoundation/build.py \
      --replace '-I''${SYSROOT}/usr/include/libxml2' '-I${libxml2.dev}/include/libxml2' \
      --replace '-DDEPLOYMENT_TARGET_MACOSX' '-DDEPLOYMENT_TARGET_MACOSX -DINCLUDE_OBJC' \
      --replace "cf.CFLAGS += '-DDEPLOYMENT" '#' \
      --replace "cf.LDFLAGS += '-ldispatch" '#' \
      --replace "'RunLoop.subproj/CFSocket.c'," "'RunLoop.subproj/CFSocket.c', 'RunLoop.subproj/CFMachPort.c', 'RunLoop.subproj/CFMessagePort.c',"

    # Includes xpc for some initialization routine that they don't define anyway, so no harm here
    substituteInPlace CoreFoundation/PlugIn.subproj/CFBundlePriv.h \
      --replace '#if (TARGET_OS_MAC' '#if (0'

    # Why do we define __GNU__? Is that normal?
    substituteInPlace CoreFoundation/Base.subproj/CFAsmMacros.h \
      --replace '#if defined(__GNU__) ||' '#if 0 &&'

    # The MIN macro doesn't seem to be defined sensibly for us. Not sure if our stdenv or their bug
    substituteInPlace CoreFoundation/Base.subproj/CoreFoundation_Prefix.h \
      --replace '#if DEPLOYMENT_TARGET_WINDOWS || DEPLOYMENT_TARGET_LINUX' '#if 1'

    # None of these functions seem swift-specific. Make a PR upstream and see
    substituteInPlace CoreFoundation/NumberDate.subproj/CFTimeZone.c \
      --replace '#if DEPLOYMENT_RUNTIME_SWIFT' '#if 1'

    # Somehow our ICU doesn't have this
    substituteInPlace CoreFoundation/Locale.subproj/CFLocale.c \
      --replace '#if U_ICU_VERSION_MAJOR_NUM' '#if 0 //'
  '';

  configurePhase = ":";

  buildPhase = ''
    cd CoreFoundation
    ../configure --sysroot unused
    ninja
  '';

  # TODO: go set up the .framework and plug in all the right headers
  installPhase = ''
    mkdir -p $out/lib
    cp ../Build/CoreFoundation/libCoreFoundation.dylib $out/lib
  '';
}
