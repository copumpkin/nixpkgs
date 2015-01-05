{ stdenv, fetchurl, cpio, bootstrap_cmds, xnu, libc, libm, libdispatch, cctools, libinfo,
  dyld, csu, architecture, libclosure, carbon-headers, ncurses, commonCrypto, copyfile,
  removefile, libresolv, libnotify, libpthread, mDNSResponder }:

stdenv.mkDerivation rec {
  version = "1197.1.1";
  name    = "Libsystem-${version}";

  src = fetchurl {
    url    = "http://www.opensource.apple.com/tarballs/Libsystem/${name}.tar.gz";
    sha256 = "1yfj2qdrf9vrzs7p9m4wlb7zzxcrim1gw43x4lvz4qydpp5kg2rh";
  };

  phases = [ "unpackPhase" "installPhase" ];

  buildInputs = [ cpio libpthread ];

  systemlibs = [ "cache"
                 "commonCrypto"
                 "compiler_rt"
                 "copyfile"
                 "corecrypto"
                 "dispatch"
                 "dyld"
                 "keymgr"
                 "kxld"
                 "launch"
                 "macho"
                 "quarantine"
                 "removefile"
                 "system_asl"
                 "system_blocks"
                 # "system_c" # special re-export here to hide newer functions
                 "system_configuration"
                 "system_dnssd"
                 "system_info"
                 # "system_kernel" # special re-export here to hide newer functions
                 "system_m"
                 "system_malloc"
                 "system_network"
                 "system_notify"
                 "system_platform"
                 "system_pthread"
                 "system_sandbox"
                 "system_stats"
                 "unc"
                 "unwind"
                 "xpc"
               ];

  installPhase = ''
    export NIX_ENFORCE_PURITY=

    mkdir -p $out/lib $out/include

    # Set up our include directories
    (cd ${xnu}/include && find . -name '*.h' | cpio -pdm $out/include)
    cp ${xnu}/Library/Frameworks/Kernel.framework/Versions/A/Headers/Availability*.h $out/include
    cp ${xnu}/Library/Frameworks/Kernel.framework/Versions/A/Headers/stdarg.h        $out/include

    for dep in ${libc} ${libm} ${libinfo} ${dyld} ${architecture} ${libclosure} ${carbon-headers} ${libdispatch} ${ncurses} ${commonCrypto} ${copyfile} ${removefile} ${libresolv} ${libnotify} ${mDNSResponder}; do
      (cd $dep/include && find . -name '*.h' | cpio -pdm $out/include)
    done

    (cd ${cctools}/include/mach-o && find . -name '*.h' | cpio -pdm $out/include/mach-o)

    cat <<EOF > $out/include/TargetConditionals.h
    #ifndef __TARGETCONDITIONALS__
    #define __TARGETCONDITIONALS__
    #define TARGET_OS_MAC           1
    #define TARGET_OS_WIN32         0
    #define TARGET_OS_UNIX          0
    #define TARGET_OS_EMBEDDED      0
    #define TARGET_OS_IPHONE        0
    #define TARGET_IPHONE_SIMULATOR 0
    #define TARGET_OS_LINUX         0
    #endif  /* __TARGETCONDITIONALS__ */
    EOF



    # The startup object files
    cp ${csu}/lib/* $out/lib

    # This probably doesn't belong here, but we want to stay similar to glibc, which includes resolv internally...
    # TODO: add darwin-conditional libresolv dependency to packages that need it instead of this...
    ln -s ${libresolv}/lib/libresolv.9.dylib $out/lib/libresolv.9.dylib
    ln -s libresolv.9.dylib $out/lib/libresolv.dylib

    # selectively re-export functions from libsystem_c and libsystem_kernel
    # to provide a consistent interface across OSX verions
    mkdir -p $out/lib/system
    ld -macosx_version_min 10.7 -arch x86_64 -dylib \
       -o $out/lib/system/libsystem_c.dylib \
       /usr/lib/libSystem.dylib \
       -reexported_symbols_list ${./system_c_symbols}

    ld -macosx_version_min 10.7 -arch x86_64 -dylib \
       -o $out/lib/system/libsystem_kernel.dylib \
       /usr/lib/libSystem.dylib \
       -reexported_symbols_list ${./system_kernel_symbols}

    # Set up the actual library link
    clang -c -o CompatibilityHacks.o -Os CompatibilityHacks.c
    clang -c -o init.o -Os init.c
    ld -macosx_version_min 10.7 \
       -arch x86_64 \
       -dylib \
       -o $out/lib/libSystem.dylib \
       CompatibilityHacks.o init.o \
       -reexport_library $out/lib/system/libsystem_c.dylib \
       -reexport_library $out/lib/system/libsystem_kernel.dylib \
        ${stdenv.lib.concatStringsSep " "
          (map (l: "-reexport_library /usr/lib/system/lib${l}.dylib") systemlibs)}

    # Set up links to pretend we work like a conventional unix (Apple's design, not mine!)
    for name in c dbm dl info m mx poll proc pthread rpcsvc gcc_s.10.4 gcc_s.10.5; do
      ln -s libSystem.dylib $out/lib/lib$name.dylib
    done
  '';

  meta = with stdenv.lib; {
    description = "The Mac OS libc/libSystem (impure symlinks to binaries with pure headers)";
    maintainers = with maintainers; [ copumpkin gridaphobe ];
    platforms   = platforms.darwin;
    license     = licenses.apsl20;
  };
}

# ld -macosx_version_min 10.6 -arch x86_64 -dylib -o $out/lib/libSystem.dylib -reexport-lSystem
