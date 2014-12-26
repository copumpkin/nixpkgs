# This file was auto-generated by cabal2nix. Please do NOT edit manually!

{ cabal, binary, blazeHtml, blazeMarkup, cmdargs, cryptohash
, dataDefault, deepseq, filepath, fsnotify, httpConduit, httpTypes
, HUnit, lrucache, mtl, network, networkUri, pandoc, pandocCiteproc
, parsec, QuickCheck, random, regexBase, regexTdfa, snapCore
, snapServer, systemFilepath, tagsoup, testFramework
, testFrameworkHunit, testFrameworkQuickcheck2, text, time
, utillinux
}:

cabal.mkDerivation (self: {
  pname = "hakyll";
  version = "4.6.1.1";
  sha256 = "1y1bc25ivj6sgq9909qgwsm54dn6sdisd1znkk9r5x9c7ajv6gaa";
  isLibrary = true;
  isExecutable = true;
  doCheck = !self.stdenv.isDarwin;
  buildDepends = [
    binary blazeHtml blazeMarkup cmdargs cryptohash dataDefault deepseq
    filepath fsnotify httpConduit httpTypes lrucache mtl network
    networkUri pandoc pandocCiteproc parsec random regexBase regexTdfa
    snapCore snapServer systemFilepath tagsoup text time
  ];
  testDepends = [
    binary blazeHtml blazeMarkup cmdargs cryptohash dataDefault deepseq
    filepath fsnotify httpConduit httpTypes HUnit lrucache mtl network
    networkUri pandoc pandocCiteproc parsec QuickCheck random regexBase
    regexTdfa snapCore snapServer systemFilepath tagsoup testFramework
    testFrameworkHunit testFrameworkQuickcheck2 text time
  ] ++ (self.stdenv.lib.optional self.stdenv.isLinux utillinux);
  meta = {
    homepage = "http://jaspervdj.be/hakyll";
    description = "A static website compiler library";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
    maintainers = with self.stdenv.lib.maintainers; [ fuuzetsu ];
  };
})
