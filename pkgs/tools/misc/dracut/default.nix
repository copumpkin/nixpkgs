{ stdenv, fetchFromGitHub, asciidoc, libxslt, docbook_xsl, docbook_xml_dtd_45,
  coreutils, utillinux, gnugrep, gnused, gzip, bzip2, xz }:

stdenv.mkDerivation rec {
  name    = "dracut-${version}";
  version = "044";

  src = fetchFromGitHub {
    owner  = "dracutdevs";
    repo   = "dracut";
    rev    = version;
    sha256 = "0hj2mjswlydmmfx2nai8nn9wsskqscgkwfn2frba1hjrd42m2vcj";
  };

  buildInputs = [ asciidoc libxslt docbook_xsl docbook_xml_dtd_45 ];

  prePatch = ''
    patchShebangs ./configure
    substituteInPlace dracut.sh \
      --replace 'getopt \' '${utillinux}/bin/getopt \' \
      --replace '/sbin /bin /usr/sbin /usr/bin' '${coreutils}/bin ${gnugrep}/bin ${gnused}/bin ${gzip}/bin ${bzip2}/bin ${xz}/bin' \
      --replace '/usr/lib/dracut' "$out/lib/dracut"
  '';

  # Lots of scripts that are supposed to end up on the target machine
  dontPatchShebangs = true;

  postInstall = ''
    patchShebangs $out/bin
  '';
}
