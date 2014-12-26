{ stdenv, fetchgit }:

stdenv.mkDerivation rec {
  name = "libsepol-${version}";
  version = "2.3";
  se_release = "20140506";
  se_url = "https://raw.githubusercontent.com/wiki/SELinuxProject/selinux/files/releases";

  src = fetchgit {
    url = "https://github.com/SELinuxProject/selinux";
    rev = "refs/tags/libsepol-${version}";
    sha256 = "0vi2k14gh512b2prnn31l0cg78lmqjqrybdgdyibbhcg2s4v5snb";
  };

  preConfigure = "cd libsepol";

  preBuild = '' makeFlags="$makeFlags PREFIX=$out DESTDIR=$out" '';

  # TODO: Figure out why the build incorrectly links libsepol.so
  postInstall = ''
    rm $out/lib/libsepol.so
    ln -s libsepol.so.1 $out/lib/libsepol.so
  '';

  passthru = { inherit se_release se_url; };

  meta = with stdenv.lib; {
    homepage = http://userspace.selinuxproject.org;
    platforms = platforms.linux;
    maintainers = [ maintainers.phreedom ];
    license = stdenv.lib.licenses.gpl2;
  };
}
