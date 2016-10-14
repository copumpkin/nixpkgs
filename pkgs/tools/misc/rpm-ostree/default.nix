{ stdenv, fetchFromGitHub, ostree, rpm, which, autoconf, automake, libtool, pkgconfig,
  libcap, glib, libgsystem, json_glib, libarchive, libsolv, librepo, gtk_doc, elfutils,
  gperf, cmake, pcre, check, python, bubblewrap, libxslt, docbook_xsl, docbook_xml_dtd_42,
  coreutils, kmod, dracut, acl, fetchpatch }:

let
  libglnx-src = fetchFromGitHub {
    owner  = "GNOME";
    repo   = "libglnx";
    rev    = "4ae5e3beaaa674abfabf7404ab6fafcc4ec547db";
    sha256 = "1npb9zbyb4bl0nxqf0pcqankcwzs3k1x8i2wkdwhgak4qcvxvfqn";
  };

  libdnf-src = fetchFromGitHub {
    owner  = "rpm-software-management";
    repo   = "libhif";
    rev    = "b69552b3b3a42fd41698a925d5f5f623667bac63";
    sha256 = "0h6k09rb4imzbmsn7mspwl0js2awqdpb4ysdqq550vw2nr0dzszr";
  };

  version = "2016.10";
in stdenv.mkDerivation {
  name = "rpm-ostree-${version}";

  src = fetchFromGitHub {
    rev    = "v${version}";
    owner  = "projectatomic";
    repo   = "rpm-ostree";
    sha256 = "0a0wwklzk1kvk3bbxxfvxgk4ck5dn7a7v32shqidb674fr2d5pvb";
  };

  buildInputs = [
    which autoconf automake pkgconfig libtool libcap ostree rpm glib libgsystem gperf
    json_glib libarchive libsolv librepo gtk_doc libxslt docbook_xsl docbook_xml_dtd_42
    cmake pcre check python
    # FIXME: get rid of this once libarchive properly propagates this
    acl
  ];

  dontUseCmakeConfigure = true;

  patches = [
    (fetchpatch {
      url    = "http://github.com/projectatomic/rpm-ostree/pull/491.patch";
      sha256 = "03kbiy0h228x2639fgp6qpxp4z7sflr4hc6gdx0lrc8gdxfzcyd6";
    })
  ];

  prePatch = ''
    rmdir libglnx libdnf
    cp --no-preserve=mode -r ${libglnx-src} libglnx
    cp --no-preserve=mode -r ${libdnf-src} libdnf

    # According to #cmake on freenode, libdnf should bundle the FindLibSolv.cmake module
    cp ${libsolv}/share/cmake/Modules/FindLibSolv.cmake libdnf/cmake/modules/

    # See https://github.com/projectatomic/rpm-ostree/issues/480
    substituteInPlace src/libpriv/rpmostree-unpacker.c --replace 'include <selinux/selinux.h>' ""

    # libdnf normally wants sphinx to build its hawkey manpages, but we don't care about those manpages since we don't use hawkey
    substituteInPlace configure.ac --replace 'cmake \' 'cmake -DWITH_MAN=off \'

    # Let's not hardcode the rpm-gpg path...
    substituteInPlace libdnf/libdnf/dnf-keyring.c \
      --replace '"/etc/pki/rpm-gpg"' 'getenv("LIBDNF_RPM_GPG_PATH_OVERRIDE") ? getenv("LIBDNF_RPM_GPG_PATH_OVERRIDE") : "/etc/pki/rpm-gpg"'

    substituteInPlace src/libpriv/rpmostree-bwrap.c \
      --replace '"--ro-bind", "usr", "/usr"' '"--ro-bind", "usr", "/usr", "--ro-bind", "/nix", "/nix"' \
      --replace '"true"' '"${coreutils}/bin/true"'

    substituteInPlace src/libpriv/rpmostree-postprocess.c \
      --replace '"--bind", "etc", "/etc",' '"--bind", "etc", "/etc", "--ro-bind", "/nix", "/nix",' \
      --replace '"depmod"' '"${kmod}/bin/depmod"' \
      --replace '"dracut"' '"/usr/bin/dracut"' # Nasty impurity for now :(
  '';

  preConfigure = ''
    env NOCONFIGURE=1 ./autogen.sh
  '';

  configureFlags = "--with-bubblewrap=${bubblewrap}/bin/bwrap";

  meta = with stdenv.lib; {
    description = "A hybrid image/package system. It uses OSTree as an image format, and uses RPM as a component model";
    homepage    = "https://rpm-ostree.readthedocs.io/en/latest/";
    license     = licenses.lgpl2Plus;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ copumpkin ];
  };
}

