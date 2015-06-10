let
  pkgs = import ./. {};
  bootstrap-tools = import ./pkgs/stdenv/darwin/make-bootstrap-tools.nix {};
in with pkgs; {
  build = buildEnv {
    name = "standard-build";
    paths = [
      bootstrap-tools.build
      nix-exec
      gitFull
      subversion
      emacs24Macport
#      texLive # slow as hell, can't be bothered to wait for it
      ocaml
      coq_HEAD
      tmux
      expect
      lua
      luajit
      nginx
      apacheHttpd
      redis
      postgresql
      mysql55
      iperf
      watch
      weechat
 #     vim # broken on 10.10 due to framework mismatches
      pass
      gnupg
    ];
    ignoreCollisions = true;
  };
}
