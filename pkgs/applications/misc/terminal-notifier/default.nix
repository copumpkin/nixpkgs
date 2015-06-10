{ stdenv, lib, fetchzip }:

stdenv.mkDerivation rec {
  name = "terminal-notifier-${version}";

  version = "1.5.0";

  src = fetchzip {
    url = "https://github.com/alloy/terminal-notifier/releases/download/${version}/terminal-notifier-${version}.zip";
    sha256 = "09x7vl0kddivqq3pyrk6sg1f0sv5l7nj0bmblq222zk3b09bgg8p";
  };

  buildPhase = "true";

  installPhase = ''
    mkdir -p $out/Applications
    mkdir -p $out/bin
    cp -r terminal-notifier.app $out/Applications

    # this used to be a simple symlink, but OSX apps appear to use the executable path to
    # try to find resource files
    cat >$out/bin/terminal-notifier <<EOF
    cd $out/Applications/terminal-notifier.app/Contents/MacOS
    exec terminal-notifier "\$@"
    EOF
    chmod +x $out/bin/terminal-notifier
  '';

  meta = with lib; {
    maintainers = with maintainers; [ cstrahan ];
    platforms   = with platforms; darwin;
  };
}
