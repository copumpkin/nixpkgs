{ stdenv, fetchurl, python, zlib, pkgconfig, glib, ncurses, perl, pixman
, attr, libcap, vde2, alsaLib, texinfo, libuuid, flex, bison, lzo, snappy
, libseccomp, libaio, libcap_ng, gnutls
, makeWrapper
, pulseSupport ? !stdenv.isDarwin, pulseaudio
, sdlSupport ? !stdenv.isDarwin, SDL
, vncSupport ? true, libjpeg, libpng
, spiceSupport ? !stdenv.isDarwin, spice, spice_protocol, usbredir
, x86Only ? false
, IOKit ? null
, libutil
}:

with stdenv.lib;
let
  n = "qemu-2.2.1";
  audio = optionalString (hasSuffix "linux" stdenv.system) "alsa,"
    + optionalString pulseSupport "pa,"
    + optionalString sdlSupport "sdl,";
in

stdenv.mkDerivation rec {
  name = n + (if x86Only then "-x86-only" else "");

  src = fetchurl {
    url = "http://wiki.qemu.org/download/${n}.tar.bz2";
    sha256 = "181m2ddsg3adw8y5dmimsi8x678imn9f6i5p20zbhi7pdr61a5s6";
  };

  buildInputs =
    [ python zlib pkgconfig glib ncurses perl pixman
      vde2 texinfo libuuid flex bison makeWrapper lzo snappy
      gnutls libutil
    ]
    ++ optionals pulseSupport [ pulseaudio ]
    ++ optionals sdlSupport [ SDL ]
    ++ optionals vncSupport [ libjpeg libpng ]
    ++ optionals spiceSupport [ spice_protocol spice usbredir ]
    ++ optionals stdenv.isLinux [ alsaLib libaio libcap libcap_ng libseccomp attr ]
    ++ optionals stdenv.isDarwin [ IOKit ];

  enableParallelBuilding = true;

  patches = [ ./no-etc-install.patch ];

  configureFlags =
    [ "--smbd=smbd" # use `smbd' from $PATH
      "--audio-drv-list=${audio}"
      "--sysconfdir=/etc"
      "--localstatedir=/var"
    ]
    ++ optional spiceSupport "--enable-spice"
    ++ optional x86Only "--target-list=i386-softmmu,x86_64-softmmu"
    ++ optionals stdenv.isLinux [ "--enable-linux-aio" "--enable-seccomp" ]
    ++ optionals stdenv.isDarwin [ "--cpu=x86_64" "--disable-cocoa" ]; # TODO: enable Cocoa

  postInstall =
    ''
      # Add a ‘qemu-kvm’ wrapper for compatibility/convenience.
      p="$out/bin/qemu-system-${if stdenv.system == "x86_64-linux" then "x86_64" else "i386"}"
      if [ -e "$p" ]; then
        makeWrapper "$p" $out/bin/qemu-kvm --add-flags "\$([ -e /dev/kvm ] && echo -enable-kvm)"
      fi
    '';

  meta = with stdenv.lib; {
    homepage = http://www.qemu.org/;
    description = "A generic and open source machine emulator and virtualizer";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ viric shlevy eelco ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
