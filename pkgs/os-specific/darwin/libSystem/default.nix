{ stdenv, fetchurl, cpio, bootstrap_cmds, xnu, libc, libm, libdispatch, cctools, libinfo,
  dyld, csu, architecture, libclosure, carbon-headers, ncurses, commonCrypto, copyfile,
  removefile, libresolv, libnotify }:

stdenv.mkDerivation rec {
  name = "libSystem";

  phases = [ "installPhase" ];

  buildInputs = [ cpio ];

  installPhase = ''
    mkdir -p $out/lib $out/include

    # Set up our include directories
    cd ${xnu}/include && find . -name '*.h' | cpio -pdm $out/include
    cp ${xnu}/System/Library/Frameworks/Kernel.framework/Versions/A/Headers/Availability*.h $out/include
    cp ${xnu}/System/Library/Frameworks/Kernel.framework/Versions/A/Headers/stdarg.h        $out/include

    for dep in ${libc} ${libm} ${libinfo} ${dyld} ${architecture} ${libclosure} ${carbon-headers} ${libdispatch} ${ncurses} ${commonCrypto} ${copyfile} ${removefile} ${libresolv} ${libnotify}; do
      cd $dep/include && find . -name '*.h' | cpio -pdm $out/include
    done

    cd ${cctools}/include/mach-o && find . -name '*.h' | cpio -pdm $out/include/mach-o

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

    # Set up the actual library link
    ln -s /usr/lib/libSystem.dylib $out/lib/libSystem.dylib

    # Set up links to pretend we work like a conventional unix (Apple's design, not mine!)
    for name in c dbm dl info m mx poll proc pthread rpcsvc gcc_s.10.4 gcc_s.10.5; do
      ln -s libSystem.dylib $out/lib/lib$name.dylib
    done
  '';

  meta = with stdenv.lib; {
    description = "The Mac OS libc/libSystem (impure symlinks to binaries with pure headers)";
    maintainers = with maintainers; [ copumpkin ];
    platforms   = platforms.darwin;
    license     = licenses.apsl20;
  };
}

# ld -macosx_version_min 10.6 -arch x86_64 -dylib -o $out/lib/libSystem.dylib -reexport-lSystem
