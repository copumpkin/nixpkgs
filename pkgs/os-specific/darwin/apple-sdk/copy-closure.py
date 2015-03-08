import sys
from os import makedirs, system, symlink, unlink, listdir, walk, readlink, rename
from os.path import basename, dirname, splitext, isdir, islink, lexists, join, realpath, relpath
from shutil import copytree, ignore_patterns, copyfile
import re
from macholib.MachO import MachO

vers = re.compile("/Versions/[^/]+/")
fmwk = re.compile("/System/Library/(Frameworks|PrivateFrameworks)/([^/]+)\.framework")

out = sys.argv[1]
sdk = sys.argv[2]
externals = sys.argv[3].split()
frameworks = sys.argv[4].split()

arch   = "x86_64"
src    = "/System/Library/"
dst    = out +  "/Library/"
links  = out +  "/.links"
libs   = out +  "/.libs"
encs   = out +  "/.e" # We don't have much room in our binary patching...
sdksrc = sdk +  "/System/Library/"

def adjustPath(owner, path):
  if basename(path) == basename(owner):
    return join(links, basename(owner))
  else:
    return "@rpath/" + basename(path)

def adjustLibrary(f):
  print "  Adjusting '%s'" % f
  sys.stdout.flush()

  # No need to carry around unnecessary architectures
  system("lipo -thin %s -output \"%s\" \"%s\" 2>/dev/null" % (arch, f, f))

  linkpath = join(links, basename(f))
  try:
    unlink(linkpath)
  except Exception:
    pass

  symlink(f, linkpath)
  macho = MachO(f)

  header = macho.headers[0]

  rel = relpath(links, dirname(f))

  header.rewriteInstallNameCommand(join(links, basename(f)).encode(sys.getfilesystemencoding()))

  # Copy closure of the dependencies
  for idx, name, filename in header.walkRelocatables():
    deplinkpath = join(links, basename(filename))
    if not lexists(deplinkpath):
      # A placeholder for us to find and replace later
      symlink("MISSING", deplinkpath)

    match = fmwk.search(filename)
    if match:
      fpath = join(match.group(1), match.group(2))
      copyFramework(fpath)

    if name == 'reexport_dylib':
      data = join(links, basename(filename))
      header.rewriteDataForCommand(idx, data.encode(sys.getfilesystemencoding()))
    else:
      data = join("@rpath", basename(filename))
      header.rewriteDataForCommand(idx, data.encode(sys.getfilesystemencoding()))


  with open(f, 'r+b') as fh:
    try:
      macho.write(fh)
    except:
      print "Could not rewrite header for '%s'" % f

  # This must come last, because the load command is long and the stuff
  # above frees up space in the header to fit it
  system("install_name_tool -add_rpath \"%s\" \"%s\"" % (links, f))

def copyFramework(fpath):
  dest = join(dst, fpath + ".framework")
  if isdir(dest):
    return

  srcpath = join(fpath + ".framework", "Versions", "Current")
  source  = join(src, srcpath)
  headers = join(sdksrc, srcpath)

  print "Copying '%s'" % fpath
  copytree(source, dest, symlinks=False, ignore=ignore)

  if (isdir(join(headers, "Headers"))):
    copytree(join(headers, "Headers"), join(dest, "Headers"))

  framework = dest

  fname = basename(splitext(framework)[0])

  adjustLibrary(join(framework, fname))

  for root, dirs, files in walk(framework):
    for name in files:
      if name.endswith(".dylib"):
        adjustLibrary(join(root, name))

  if isdir(join(source, "Frameworks")):
    for child in listdir(join(source, "Frameworks")):
      if islink(join(source, "Frameworks", child)):
        linkto = readlink(join(source, "Frameworks", child))
        target = relpath(realpath(join(source, "Frameworks", linkto)), src)

        symlink(join(dst, target), join(dest, "Frameworks", child))
      elif child.endswith(".framework"):
        copyFramework(join(fpath + ".framework", "Frameworks", splitext(child)[0]))
      else:
        copytree(join(source, "Frameworks", child), join(dest, "Frameworks", child))

ignore = ignore_patterns("Frameworks", "Headers", "Versions", "_CodeSignature")


# When relinking the libraries, there often isn't enough space in the header to do it the obvious
# way, so we create a folder containing links to all our dependencies (internal and external),
# rewrite all references to point to @rpath/.links, and then add a single rpath command pointing at it.
# N.B: assumes there are no filename conflicts in different paths!
makedirs(links)

for f in frameworks:
  copyFramework("Frameworks/" + f)

makedirs(libs)

def absorb(lib):
  name = basename(lib)
  copyfile(lib, join(libs, name))
  adjustLibrary(join(libs, name))
  unlink(join(links, name))
  symlink(join("../.libs/", name), join(links, name))

absorb("/usr/lib/liblangid.dylib")
absorb("/usr/lib/libOpenScriptingUtil.dylib")
absorb("/usr/lib/libDiagnosticMessagesClient.dylib")
absorb("/usr/lib/libcsfde.dylib")
absorb("/usr/lib/libCoreStorage.dylib")

# FIXME: we can/should build these
absorb("/usr/lib/libCRFSuite.dylib")
absorb("/usr/lib/libcups.2.dylib")
absorb("/usr/lib/libbz2.1.0.dylib")
absorb("/usr/lib/libheimdal-asn1.dylib")

# Needed by SystemConfiguration. Our existing bsm lib doesn't provide all the symbols they need
# and the source for theirs isn't public. Might be able to remove this if we are able to relink
# all their things against our SystemConfiguration framework.
absorb("/usr/lib/libbsm.0.dylib")

# Another one that can probably go away someday
absorb("/usr/lib/libiconv.2.dylib")

absorb("/usr/lib/libpcap.A.dylib")

absorb("/usr/lib/libsandbox.1.dylib")
absorb("/usr/lib/libsqlite3.dylib")
absorb("/usr/lib/libMatch.1.dylib")

makedirs(encs)

def absorbEncoding(enc, d):
  copytree(join(src, "TextEncodings", enc), join(encs, d))
  bin = join(encs, d, "Contents", "MacOS", splitext(d)[0])
  rename(join(encs, d, "Contents", "MacOS", splitext(enc)[0]), bin)
  adjustLibrary(bin)

absorbEncoding( "Unicode Encodings.bundle", "U.bundle")
absorbEncoding( "Chinese Encodings.bundle", "C.bundle")
absorbEncoding("Japanese Encodings.bundle", "J.bundle")
absorbEncoding(  "Korean Encodings.bundle", "K.bundle")

# Only makes sense when the prefix of f of length t is reasonably long and unique...
def binReplace(str, f, t):
  if len(t) > len(f):
    print "Doesn't fit! '%s' -> '%s'" % (f, t)
    raise

  needle = f[0:len(t) + 1]
  return str.replace(needle, t + '\0')


with open(join(dst, "Frameworks", "CoreServices.framework", "Frameworks", "CarbonCore.framework", "CarbonCore"), 'r+b') as f:
  s = f.read()
  s = binReplace(s, b'file://localhost/System/Library/TextEncodings/Unicode%20Encodings.bundle/', ('file://' + join(encs, 'U.bundle/')).encode('ascii'))
  s = binReplace(s, b'file://localhost/System/Library/TextEncodings/Chinese%20Encodings.bundle/', ('file://' + join(encs, 'C.bundle/')).encode('ascii'))
  s = binReplace(s, b'file://localhost/System/Library/TextEncodings/Japanese%20Encodings.bundle/', ('file://' + join(encs, 'J.bundle/')).encode('ascii'))
  s = binReplace(s, b'file://localhost/System/Library/TextEncodings/Korean%20Encodings.bundle/', ('file://' + join(encs, 'K.bundle/')).encode('ascii'))
  f.seek(0)
  f.write(s)


with open(join(dst, "Frameworks", "Kerberos.framework", "Kerberos"), 'r+b') as f:
  s = f.read()
  s = binReplace(s, b'/System/Library/PrivateFrameworks/Heimdal.framework/Heimdal', '@rpath/Heimdal')
  s = binReplace(s, b'/System/Library/PrivateFrameworks/GSS.framework/GSS', '@rpath/GSS')
  f.seek(0)
  f.write(s)

# Now let's fix up the missing links using the externals our kind caller passed in

# I could make these into a map, but probably not worth it
def findExternal(name):
  for external in externals:
    if basename(external) == name:
      return external
    else:
      for subpath in ["", "lib"]:
        if isdir(join(external, subpath)):
          for child in listdir(join(external, subpath)):
            if child == name:
              return join(external, subpath, child)

for link in listdir(links):
  if readlink(join(links, link)) == "MISSING":
    external = findExternal(link)
    if external:
      unlink(join(links, link))
      symlink(external, join(links, link))
    else:
      print link + " not found :("
