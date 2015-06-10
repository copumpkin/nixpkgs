# Current as of 10.9
# Epic weird knot-tying happening here.
# TODO: clean up the process for generating this and include it

{ frameworks, libs }:

with frameworks; with libs; {
  AGL                     = [ Carbon OpenGL ];
  AVFoundation            = [ ApplicationServices CoreGraphics ];
  AVKit                   = [];
  Accounts                = [];
  AddressBook             = [ Carbon CoreFoundation ];
  AppKit                  = [ QuartzCore ];
  AppKitScripting         = [];
  AppleScriptKit          = [];
  AppleScriptObjC         = [];
  AppleShareClientCore    = [ CoreServices ];
  AudioToolbox            = [ AudioUnit CoreAudio CoreFoundation CoreMIDI ];
  AudioUnit               = [ Carbon CoreAudio CoreFoundation ];
  AudioVideoBridging      = [ Foundation ];
  Automator               = [];
  CFNetwork               = [ CoreFoundation ];
  CalendarStore           = [];
  Cocoa                   = [];
  Collaboration           = [];
  CoreAudio               = [ CoreFoundation IOKit ];
  CoreAudioKit            = [ AudioUnit ];
  CoreData                = [];
  CoreFoundation          = [];
  CoreGraphics            = [ CoreFoundation IOKit IOSurface ];
  CoreLocation            = [];
  CoreMIDI                = [ CoreFoundation ];
  CoreMIDIServer          = [];
  CoreMedia               = [ ApplicationServices AudioToolbox CoreAudio CoreFoundation CoreGraphics CoreVideo ];
  CoreMediaIO             = [ CoreFoundation CoreMedia ];
  CoreText                = [ CoreFoundation CoreGraphics ];
  CoreVideo               = [ ApplicationServices CoreFoundation CoreGraphics IOSurface OpenGL ];
  CoreWLAN                = [];
  DVComponentGlue         = [ CoreServices QuickTime ];
  DVDPlayback             = [];
  DirectoryService        = [ CoreFoundation ];
  DiscRecording           = [ CoreFoundation CoreServices IOKit ];
  DiscRecordingUI         = [];
  DiskArbitration         = [ CoreFoundation IOKit ];
  DrawSprocket            = [ Carbon ];
  EventKit                = [];
  ExceptionHandling       = [];
  FWAUserLib              = [];
  ForceFeedback           = [ CoreFoundation IOKit ];
  Foundation              = [ CoreFoundation Security ApplicationServices AppKit ];
  GLKit                   = [ CoreFoundation ];
  GLUT                    = [ GL OpenGL ];
  GSS                     = [];
  GameController          = [];
  GameKit                 = [ Foundation ];
  ICADevices              = [ Carbon CoreFoundation IOBluetooth ];
  IMServicePlugIn         = [];
  IOBluetoothUI           = [ IOBluetooth ];
  IOKit                   = [ CoreFoundation ];
  IOSurface               = [ CoreFoundation IOKit xpc ];
  ImageCaptureCore        = [];
  ImageIO                 = [ CoreFoundation CoreGraphics ];
  InputMethodKit          = [ Carbon ];
  InstallerPlugins        = [];
  InstantMessage          = [];
  JavaFrameEmbedding      = [];
  JavaScriptCore          = [ CoreFoundation ];
  Kerberos                = [];
  Kernel                  = [ CoreFoundation IOKit ];
  LDAP                    = [];
  LatentSemanticMapping   = [ Carbon CoreFoundation ];
  MapKit                  = [];
  MediaAccessibility      = [ CoreFoundation CoreGraphics CoreText QuartzCore ];
  MediaToolbox            = [ AudioToolbox CoreFoundation CoreMedia ];
  NetFS                   = [ CoreFoundation ];
  OSAKit                  = [ Carbon ];
  OpenAL                  = [];
  OpenCL                  = [ CL IOSurface OpenGL ];
  OpenGL                  = [];
  PCSC                    = [];
  PreferencePanes         = [];
  PubSub                  = [];
  Python                  = [ ApplicationServices ];
  QTKit                   = [ QuickTime ];
  QuickLook               = [ ApplicationServices CoreFoundation ];
  QuickTime               = [ ApplicationServices AudioUnit Carbon CoreAudio CoreServices OpenGL QuartzCore ];
  Ruby                    = [];
  RubyCocoa               = [];
  SceneKit                = [];
  ScreenSaver             = [];
  Scripting               = [];
  ScriptingBridge         = [];
  Security                = [ CoreFoundation ];
  SecurityFoundation      = [];
  SecurityInterface       = [ Security ];
  ServiceManagement       = [ CoreFoundation Security ];
  Social                  = [];
  SpriteKit               = [];
  StoreKit                = [];
  SyncServices            = [];
  SystemConfiguration     = [ CoreFoundation Security ];
  TWAIN                   = [ Carbon ];
  Tcl                     = [];
  Tk                      = [ ApplicationServices Carbon X11 ];
  VideoDecodeAcceleration = [ CoreFoundation CoreVideo ];
  VideoToolbox            = [ CoreFoundation CoreMedia CoreVideo ];
  WebKit                  = [ ApplicationServices Carbon JavaScriptCore OpenGL X11 ];

  # Umbrellas
  Accelerate          = [ CoreGraphics ];
  ApplicationServices = [ CoreFoundation CoreServices CoreText ImageIO ];
  Carbon              = [ ApplicationServices CoreFoundation CoreServices IOKit Security ];
  CoreServices        = [ CFNetwork CoreFoundation DiskArbitration Security ];
  IOBluetooth         = [ IOKit ];
  JavaVM              = [];
  OpenDirectory       = [ CoreFoundation Foundation ];
  Quartz              = [ QuickLook ];
  QuartzCore          = [ ApplicationServices CoreFoundation CoreVideo ];
}
