#!/bin/sh -eu

# Mac OS is weird about its sandbox. The .sb file doesn't need to be executable, but it does need
# to be touched in a way that touch doesn't do, otherwise there's some weird caching mechanism that
# stops the OS from noticing the file changed below.
chmod +x ./pure.sb

# This stuff should all work in the sandbox
sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A build ./pkgs/stdenv/darwin/make-bootstrap-tools.nix
sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A nix-exec
sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A gitFull
sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A subversion
sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A emacs24Macport
sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A texLive
sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A ocaml
sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A coq_HEAD
sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A tmux
sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A expect
sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A lua
sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A luajit

sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A nginx
sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A apacheHttpd

sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A redis
sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A postgresql
sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A mysql55

sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A iperf
sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A watch

# Broken builds (for now)
# sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A nodejs (wants CoreServices framework)
# sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A openjdk (binary bootstrap references root)
# sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A sbcl (binary bootstrap references root)
# sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A isabelle
# sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A erlang (missing Carbon framework)
# sandbox-exec -D _HOME=$HOME -f ./pure.sb nix-build --option use-binary-caches false -K -j 4 -A swiProlog (tries to write to /etc)
