{ stdenv, appleDerivation, fetchzip, bootstrap_cmds, dtrace, bison, flex, gnum4, unifdef, perl, python, binutils, llvm }:

appleDerivation {
  buildInputs = [ bootstrap_cmds bison flex gnum4 unifdef perl python ];

  patches = [ ./restore-section-keywords.patch ];

  prePatch = ''
    substituteInPlace Makefile \
      --replace "/bin/" "" \

    substituteInPlace makedefs/MakeInc.cmd \
      --replace "/usr/bin/" "" \
      --replace "/bin/" ""

    substituteInPlace makedefs/MakeInc.def \
      --replace "-c -S -m" "-c -m" \
      --replace "-Werror " "" \
      --replace "-freorder-blocks " ""

    substituteInPlace makedefs/MakeInc.kernel \
      --replace '$(_v)$(MV)' '$(_v)echo'

    substituteInPlace makedefs/MakeInc.top \
      --replace "MEMORY_SIZE := " 'MEMORY_SIZE := 1073741824 # '

    substituteInPlace libkern/kxld/Makefile \
      --replace "-Werror " ""

    substituteInPlace SETUP/kextsymboltool/Makefile \
      --replace "-lstdc++" "-lc++"

    substituteInPlace libsyscall/xcodescripts/mach_install_mig.sh \
      --replace "/usr/include" "/include" \
      --replace "/usr/local/include" "/include" \
      --replace "MIG=" "# " \
      --replace "MIGCC=" "# " \
      --replace '$SRC/$mig' '-I$DSTROOT/include $SRC/$mig' \
      --replace '$SRC/servers/netname.defs' '-I$DSTROOT/include $SRC/servers/netname.defs'

    substituteInPlace osfmk/kern/waitq.c \
      --replace "(typeof(waitq->waitq_eventmask))" ""

    substituteInPlace config/Makefile \
      --replace "do_config_all:: build_symbol_sets" "do_config_all::" \
      --replace '$(DSTROOT)/$(KRESDIR)/$(MD_SUPPORTED_KPI_FILENAME) \' "" \
      --replace '$(DSTROOT)/$(KRESDIR)/$(MI_SUPPORTED_KPI_FILENAME)' ""

    patchShebangs .
  '';

  ARCH_CONFIGS = "X86_64";
  KERNEL_CONFIGS = "RELEASE";
  PLATFORM = "MacOSX";
  SDKVERSION = "10.11";

  CC = "cc";
  CXX = "c++";
  MIG = "${bootstrap_cmds}/bin/mig";
  MIGCOM = "${bootstrap_cmds}/libexec/migcom";
  STRIP = "${binutils}/bin/strip";
  LIPO = "${binutils}/bin/lipo";
  LIBTOOL = "sentinel-missing-libtool";
  NM = "${binutils}/bin/nm";
  UNIFDEF = "${unifdef}/bin/unifdef";

  # llvm-dsymutil isn't powerful enough and Apple hasn't upstreamed their llvm-dsymutil on opensource.apple.com :(
  # So instead we make DSYMUTIL not do anything and pass in BUILD_DSYM=0 below
  DSYMUTIL = "echo dsymutil not used";

  CTFCONVERT = "${dtrace}/bin/ctfconvert";
  CTFMERGE = "${dtrace}/bin/ctfmerge";
  CTFINSERT = "echo ctfinsert";
  NMEDIT = "sentinel-missing-nmedit";
  INCDIR = "/";

  HOST_OS_VERSION = "10.11";
  HOST_CC = "cc";
  HOST_FLEX = "${flex}/bin/flex";
  HOST_BISON = "${bison}/bin/bison";
  HOST_GM4 = "${gnum4}/bin/m4";
  HOST_CODESIGN = "echo dummy_codesign";
  HOST_CODESIGN_ALLOCATE = "echo";

  buildPhase = ''
    # This is a bit of a hack...
    mkdir -p sdk/usr/local/libexec

    cat > sdk/usr/local/libexec/availability.pl <<EOF
      #!$SHELL
      if [ "\$1" == "--macosx" ]; then
        echo 10.0 10.1 10.2 10.3 10.4 10.5 10.6 10.7 10.8 10.9 10.10 10.11
      elif [ "\$1" == "--ios" ]; then
        echo 2.0 2.1 2.2 3.0 3.1 3.2 4.0 4.1 4.2 4.3 5.0 5.1 6.0 6.1 7.0 8.0 9.0
      fi
    EOF
    chmod +x sdk/usr/local/libexec/availability.pl

    export SDKROOT_RESOLVED=$PWD/sdk
    export HOST_SDKROOT_RESOLVED=$PWD/sdk
    export MAKEJOBS="$NIX_BUILD_CORES"

    export DSTROOT=$out
    make BUILD_LTO=0 BUILD_DSYM=0
  '';

  installPhase = ''
    mkdir -p $out/include

    # mv $out/usr/include $out
    # rmdir $out/usr

    # TODO: figure out why I need to do this
    cp libsyscall/wrappers/*.h $out/include
    mkdir -p $out/include/os
    cp libsyscall/os/tsd.h $out/include/os/tsd.h
    cp EXTERNAL_HEADERS/AssertMacros.h $out/include

    # Build the mach headers we crave
    export MIGCC=cc
    export ARCHS="x86_64"
    export SRCROOT=$PWD/libsyscall
    export DERIVED_SOURCES_DIR=$out/include
    export SDKROOT=$out
    # libsyscall/xcodescripts/mach_install_mig.sh

    # Get rid of the System prefix
    # mv $out/System/* $out/

    # Add some symlinks
    #ln -s $out/Library/Frameworks/System.framework/Versions/B \
    #      $out/Library/Frameworks/System.framework/Versions/Current
    #ln -s $out/Library/Frameworks/System.framework/Versions/Current/PrivateHeaders \
    #      $out/Library/Frameworks/System.framework/Headers

    mv BUILD $out

    ## IOKit (and possibly the others) is incomplete, so let's not make it visible from here...
    #mkdir $out/Library/PrivateFrameworks
    #mv $out/Library/Frameworks/IOKit.framework $out/Library/PrivateFrameworks
  '';
}
