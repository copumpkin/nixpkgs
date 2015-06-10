{ pkgs }:

with import ./lib.nix { inherit pkgs; };

self: super: {

  # Use the latest LLVM.
  inherit (pkgs) llvmPackages;

  # Disable GHC 7.11.x core libraries.
  array = null;
  base = null;
  binary = null;
  bin-package-db = null;
  bytestring = null;
  Cabal = null;
  containers = null;
  deepseq = null;
  directory = null;
  filepath = null;
  ghc-prim = null;
  haskeline = null;
  hoopl = null;
  hpc = null;
  integer-gmp = null;
  pretty = null;
  process = null;
  rts = null;
  template-haskell = null;
  terminfo = null;
  time = null;
  transformers = null;
  unix = null;
  xhtml = null;

  # We have Cabal 1.22.x.
  jailbreak-cabal = super.jailbreak-cabal.override { Cabal = null; };

  # GHC 7.10.x's Haddock binary cannot generate hoogle files.
  # https://ghc.haskell.org/trac/ghc/ticket/9921
  mkDerivation = drv: super.mkDerivation (drv // { doHoogle = false; });

  # haddock: No input file(s).
  nats = dontHaddock super.nats;

  # We have time 1.5
  aeson = disableCabalFlag super.aeson "old-locale";

  # Setup: At least the following dependencies are missing: base <4.8
  hspec-expectations = overrideCabal super.hspec-expectations (drv: {
    patchPhase = "sed -i -e 's|base < 4.8|base|' hspec-expectations.cabal";
  });
  utf8-string = overrideCabal super.utf8-string (drv: {
    patchPhase = "sed -i -e 's|base >= 3 && < 4.8|base|' utf8-string.cabal";
  });

  bytestring-builder = dontHaddock super.bytestring-builder;

  # bos/attoparsec#92
  attoparsec = dontCheck super.attoparsec;

  # test suite hangs silently for at least 10 minutes
  split = dontCheck super.split;

  # Test suite fails with some (seemingly harmless) error.
  # https://code.google.com/p/scrapyourboilerplate/issues/detail?id=24
  syb = dontCheck super.syb;

  # Test suite has stricter version bounds
  retry = dontCheck super.retry;

  # Test suite fails with time >= 1.5
  http-date = dontCheck super.http-date;

  # Version 1.19.5 fails its test suite.
  happy = dontCheck super.happy;

  # Workaround for a workaround, see comment for "ghcjs" flag.
  jsaddle = let jsaddle' = disableCabalFlag super.jsaddle "ghcjs";
            in addBuildDepends jsaddle' [ self.glib self.gtk3 self.webkitgtk3
                                          self.webkitgtk3-javascriptcore ];

  # The compat library is empty in the presence of mtl 2.2.x.
  mtl-compat = dontHaddock super.mtl-compat;

  # Test suite fails in "/tokens_bytestring_unicode.g.bin".
  alex = dontCheck super.alex;

  # Test suite hangs silently without consuming any CPU.
  # https://github.com/ndmitchell/extra/issues/4
  extra = dontCheck super.extra;

  # pretty-printer bug causes spurious test failures
  haskell-src-exts = dontCheck super.haskell-src-exts;

  wreq = overrideCabal super.wreq (drv: {
    patchPhase = ''
      substituteInPlace Network/Wreq/Internal/AWS.hs --replace System.Locale Data.Time.Format
      substituteInPlace Network/Wreq/Cache.hs \
        --replace System.Locale Data.Time.Format \
        --replace RecordWildCards "RecordWildCards, FlexibleContexts"
    '';
  });

  smallcheck = overrideCabal super.smallcheck (drv: {
    patchPhase = ''
      substituteInPlace Test/SmallCheck/Property.hs \
        --replace 'm ~ n' 'Monad n, m ~ n'
    '';
  });
  contravariant = overrideCabal super.contravariant (drv: {
    patchPhase = ''
      substituteInPlace src/Data/Functor/Contravariant/Compose.hs \
        --replace '<$>' '`fmap`'
    '';
  });
  semigroupoids = appendPatch super.semigroupoids (pkgs.fetchpatch {
    url = "https://github.com/ekmett/semigroupoids/commit/9d47b9f6591848543c71f901c581422d4b80a3de.patch";
    sha256 = "0xq1hxj7yfd9196nwg2x9vqpx9nd68s5gbrkylpdfwicfaavvil0";
  });
  yesod-auth = overrideCabal super.yesod-auth (drv: {
    patchPhase = ''
      substituteInPlace Yesod/Auth/Email.hs --replace \
        FlexibleContexts 'FlexibleContexts, ConstrainedClassMethods'
    '';
  });
  mono-traversable = overrideCabal super.mono-traversable (drv: {
    patchPhase = ''
      substituteInPlace src/Data/MonoTraversable.hs --replace \
        FlexibleContexts 'FlexibleContexts, ConstrainedClassMethods'
      substituteInPlace src/Data/Sequences.hs --replace \
        'c ~ Char' 'c ~ Char, IsString [c]'
    '';
  });
}
