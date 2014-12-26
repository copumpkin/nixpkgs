{ stdenv, fetchurl, xnu }:

# Someday it'll make sense to split these out into their own packages, but today is not that day.
let
  audio = fetchurl {
    url    = "http://www.opensource.apple.com/tarballs/IOAudioFamily/IOAudioFamily-197.4.2.tar.gz";
    sha256 = "1dmrczdmbdkvnhjbv233wx4xczgpf5wjrhr83aizrwpks5avkxbr";
  };
  firewire = fetchurl {
    url    = "http://www.opensource.apple.com/tarballs/IOFireWireFamily/IOFireWireFamily-455.4.0.tar.gz";
    sha256 = "034n2v6z7lf1cx3sp3309z4sn8mkchjcrsf177iag46yzlzcjgfl";
  };
  firewire_dv = fetchurl {
    url    = "http://www.opensource.apple.com/tarballs/IOFWDVComponents/IOFWDVComponents-207.4.1.tar.gz";
    sha256 = "1brr0yn6mxgapw3bvlhyissfksifzj2mqsvj9vmps6zwcsxjfw7m";
  };
  firewire_avc = fetchurl {
    url    = "http://www.opensource.apple.com/tarballs/IOFireWireAVC/IOFireWireAVC-422.4.0.tar.gz";
    sha256 = "1anw8cfmwkavnrs28bzshwa3cwk4r1p3x72561zljx57d0na9164";
  };
  firewire_sbp2 = fetchurl {
    url    = "http://www.opensource.apple.com/tarballs/IOFireWireSBP2/IOFireWireSBP2-426.4.1.tar.gz";
    sha256 = "0asik6qjhf3jjp22awsiyyd6rj02zwnx47l0afbwmxpn5bchfk60";
  };
  firewire_sbpt = fetchurl {
    url    = "http://opensource.apple.com/tarballs/IOFireWireSerialBusProtocolTransport/IOFireWireSerialBusProtocolTransport-251.0.1.tar.gz";
    sha256 = "09kiq907qpk94zbij1mrcfcnyyc5ncvlxavxjrj4v5braxm78lhi";
  };
  graphics = fetchurl {
    url    = "http://www.opensource.apple.com/tarballs/IOGraphics/IOGraphics-471.92.1.tar.gz";
    sha256 = "1c110c9chafy5ilvnc08my9ka530aljggbn66gh3sjsg7lzck9nb";
  };
  hid = fetchurl {
    url    = "http://www.opensource.apple.com/tarballs/IOHIDFamily/IOHIDFamily-503.215.2.tar.gz";
    sha256 = "0nx9mzdw848y6ppcfvip3ybczd1fxkr413zhi9qhw7gnpvac5g3n";
  };
  networking = fetchurl {
    url    = "http://www.opensource.apple.com/tarballs/IONetworkingFamily/IONetworkingFamily-100.tar.gz";
    sha256 = "10r769mqq7aiksdsvyz76xjln0lg7dj4pkg2x067ygyf9md55hlz";
  };
  serial = fetchurl {
    url    = "http://www.opensource.apple.com/tarballs/IOSerialFamily/IOSerialFamily-64.1.1.tar.gz";
    sha256 = "1bfkqmg7clwm23byr3iji812j7v1p6565b1ri6p78zviqxnxh7cx";
  };
  storage = fetchurl {
    url    = "http://www.opensource.apple.com/tarballs/IOStorageFamily/IOStorageFamily-172.tar.gz";
    sha256 = "0w5yr8ppl82anwph2zba0ppjji6ipf5x410zhcm1drzwn4bbkxrj";
  };
  storage_bd = fetchurl {
    url    = "http://opensource.apple.com/tarballs/IOBDStorageFamily/IOBDStorageFamily-14.tar.gz";
    sha256 = "1rbvmh311n853j5qb6hfda94vym9wkws5w736w2r7dwbrjyppc1q";
  };
  storage_cd = fetchurl {
    url    = "http://opensource.apple.com/tarballs/IOCDStorageFamily/IOCDStorageFamily-51.tar.gz";
    sha256 = "1905sxwmpxdcnm6yggklc5zimx1558ygm3ycj6b34f9h48xfxzgy";
  };
  storage_dvd = fetchurl {
    url    = "http://opensource.apple.com/tarballs/IODVDStorageFamily/IODVDStorageFamily-35.tar.gz";
    sha256 = "1fv82rn199mi998l41c0qpnlp3irhqp2rb7v53pxbx7cra4zx3i6";
  };
  # There should be an IOStreamFamily project here, but they haven't released it :(
  usb = fetchurl {
    url    = "http://www.opensource.apple.com/tarballs/IOUSBFamily/IOUSBFamily-630.4.5.tar.gz"; # This is from 10.8 :(
    sha256 = "1znqb6frxgab9mkyv7csa08c26p9p0ip6hqb4wm9c7j85kf71f4j";
  };
  usb_older = fetchurl {
    url    = "http://www.opensource.apple.com/tarballs/IOUSBFamily/IOUSBFamily-560.4.2.tar.gz"; # This is even older :(
    sha256 = "113lmpz8n6sibd27p42h8bl7a6c3myc6zngwri7gnvf8qlajzyml";
  };
  user = fetchurl {
    url    = "http://www.opensource.apple.com/tarballs/IOKitUser/IOKitUser-907.100.13.tar.gz";
    sha256 = "0kcbrlyxcyirvg5p95hjd9k8a01k161zg0bsfgfhkb90kh2s8x0m";
  };
  # There should be an IOVideo here, but they haven't released it :(
in stdenv.mkDerivation rec {
  version = "907.100.13";
  name    = "IOKit-${version}";

  srcs = [
    audio firewire firewire_dv firewire_avc firewire_sbp2 firewire_sbpt graphics hid
    networking serial storage storage_bd storage_cd storage_dvd usb usb_older user
  ];
  sourceRoot = ".";

  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    ###### IMPURITIES
    mkdir -p $out/Library/Frameworks/IOKit.framework
    pushd $out/Library/Frameworks/IOKit.framework
    ln -s /System/Library/Frameworks/IOKit.framework/IOKit
    ln -s /System/Library/Frameworks/IOKit.framework/Resources
    popd

    ###### HEADERS

    export dest=$out/Library/Frameworks/IOKit.framework/Headers
    mkdir -p $dest

    pushd $dest
    mkdir audio avc DV firewire graphics hid hidsystem i2c kext ndrvsupport
    mkdir network ps pwr_mgt sbp2 scsi serial storage stream usb video
    popd

    # root: complete
    cp IOKitUser-907.100.13/IOCFBundle.h                                       $dest
    cp IOKitUser-907.100.13/IOCFPlugIn.h                                       $dest
    cp IOKitUser-907.100.13/IOCFSerialize.h                                    $dest
    cp IOKitUser-907.100.13/IOCFUnserialize.h                                  $dest
    cp IOKitUser-907.100.13/IOCFURLAccess.h                                    $dest
    cp IOKitUser-907.100.13/IODataQueueClient.h                                $dest
    cp IOKitUser-907.100.13/IOKitLib.h                                         $dest
    cp IOKitUser-907.100.13/iokitmig.h                                         $dest
    cp ${xnu}/System/Library/Frameworks/IOKit.framework/Versions/A/Headers/*.h $dest

    # audio: complete
    cp IOAudioFamily-197.4.2/IOAudioDefines.h          $dest/audio
    cp IOKitUser-907.100.13/audio.subproj/IOAudioLib.h $dest/audio
    cp IOAudioFamily-197.4.2/IOAudioTypes.h            $dest/audio

    # avc: complete
    cp IOFireWireAVC-422.4.0/IOFireWireAVC/IOFireWireAVCConsts.h $dest/avc
    cp IOFireWireAVC-422.4.0/IOFireWireAVCLib/IOFireWireAVCLib.h $dest/avc

    # DV: complete
    cp IOFWDVComponents-207.4.1/DVFamily.h $dest/DV

    # firewire: complete
    cp IOFireWireFamily-455.4.0/IOFireWireFamily.kmodproj/IOFireWireFamilyCommon.h $dest/firewire
    cp IOFireWireFamily-455.4.0/IOFireWireLib.CFPlugInProj/IOFireWireLib.h         $dest/firewire
    cp IOFireWireFamily-455.4.0/IOFireWireLib.CFPlugInProj/IOFireWireLibIsoch.h    $dest/firewire
    cp IOFireWireFamily-455.4.0/IOFireWireFamily.kmodproj/IOFWIsoch.h              $dest/firewire

    # graphics: missing AppleGraphicsDeviceControlUserCommand.h
    cp IOGraphics-471.92.1/IOGraphicsFamily/IOKit/graphics/IOAccelClientConnect.h     $dest/graphics
    cp IOGraphics-471.92.1/IOGraphicsFamily/IOKit/graphics/IOAccelSurfaceConnect.h    $dest/graphics
    cp IOGraphics-471.92.1/IOGraphicsFamily/IOKit/graphics/IOAccelTypes.h             $dest/graphics
    cp IOGraphics-471.92.1/IOGraphicsFamily/IOKit/graphics/IOFramebufferShared.h      $dest/graphics
    cp IOGraphics-471.92.1/IOGraphicsFamily/IOKit/graphics/IOGraphicsEngine.h         $dest/graphics
    cp IOGraphics-471.92.1/IOGraphicsFamily/IOKit/graphics/IOGraphicsInterface.h      $dest/graphics
    cp IOGraphics-471.92.1/IOGraphicsFamily/IOKit/graphics/IOGraphicsInterfaceTypes.h $dest/graphics
    cp IOKitUser-907.100.13/graphics.subproj/IOGraphicsLib.h                          $dest/graphics
    cp IOGraphics-471.92.1/IOGraphicsFamily/IOKit/graphics/IOGraphicsTypes.h          $dest/graphics

    # hid: complete
    cp IOKitUser-907.100.13/hid.subproj/IOHIDBase.h         $dest/hid
    cp IOKitUser-907.100.13/hid.subproj/IOHIDDevice.h       $dest/hid
    cp IOKitUser-907.100.13/hid.subproj/IOHIDDevicePlugIn.h $dest/hid
    cp IOKitUser-907.100.13/hid.subproj/IOHIDElement.h      $dest/hid
    cp IOKitUser-907.100.13/hid.subproj/IOHIDLib.h          $dest/hid
    cp IOKitUser-907.100.13/hid.subproj/IOHIDManager.h      $dest/hid
    cp IOKitUser-907.100.13/hid.subproj/IOHIDQueue.h        $dest/hid
    cp IOKitUser-907.100.13/hid.subproj/IOHIDTransaction.h  $dest/hid
    cp IOKitUser-907.100.13/hid.subproj/IOHIDValue.h        $dest/hid
    cp IOHIDFamily-503.215.2/IOHIDFamily/IOHIDKeys.h        $dest/hid
    cp IOHIDFamily-503.215.2/IOHIDFamily/IOHIDUsageTables.h $dest/hid
    cp IOHIDFamily-503.215.2/IOHIDLib/IOHIDLibObsolete.h    $dest/hid

    # hidsystem: complete
    cp IOHIDFamily-503.215.2/IOHIDSystem/IOKit/hidsystem/ev_keymap.h      $dest/hidsystem
    cp IOKitUser-907.100.13/hidsystem.subproj/event_status_driver.h       $dest/hidsystem
    cp IOKitUser-907.100.13/hidsystem.subproj/IOHIDLib.h                  $dest/hidsystem
    cp IOHIDFamily-503.215.2/IOHIDSystem/IOKit/hidsystem/IOHIDParameter.h $dest/hidsystem
    cp IOHIDFamily-503.215.2/IOHIDSystem/IOKit/hidsystem/IOHIDShared.h    $dest/hidsystem
    cp IOHIDFamily-503.215.2/IOHIDSystem/IOKit/hidsystem/IOHIDTypes.h     $dest/hidsystem
    cp IOHIDFamily-503.215.2/IOHIDSystem/IOKit/hidsystem/IOLLEvent.h      $dest/hidsystem


    # i2c: complete
    cp IOGraphics-471.92.1/IOGraphicsFamily/IOKit/i2c/IOI2CInterface.h $dest/i2c

    # kext: complete
    cp IOKitUser-907.100.13/kext.subproj/KextManager.h $dest/kext

    # ndrvsupport: complete
    cp IOGraphics-471.92.1/IONDRVSupport/IOKit/ndrvsupport/IOMacOSTypes.h $dest/ndrvsupport
    cp IOGraphics-471.92.1/IONDRVSupport/IOKit/ndrvsupport/IOMacOSVideo.h $dest/ndrvsupport

    # network: complete
    cp IONetworkingFamily-100/IOEthernetController.h       $dest/network
    cp IONetworkingFamily-100/IOEthernetInterface.h        $dest/network
    cp IONetworkingFamily-100/IOEthernetStats.h            $dest/network
    cp IONetworkingFamily-100/IONetworkController.h        $dest/network
    cp IONetworkingFamily-100/IONetworkData.h              $dest/network
    cp IONetworkingFamily-100/IONetworkInterface.h         $dest/network
    cp IOKitUser-907.100.13/network.subproj/IONetworkLib.h $dest/network
    cp IONetworkingFamily-100/IONetworkMedium.h            $dest/network
    cp IONetworkingFamily-100/IONetworkStack.h             $dest/network
    cp IONetworkingFamily-100/IONetworkStats.h             $dest/network
    cp IONetworkingFamily-100/IONetworkUserClient.h        $dest/network

    # ps: missing IOUPSPlugIn.h
    cp IOKitUser-907.100.13/ps.subproj/IOPowerSources.h $dest/ps
    cp IOKitUser-907.100.13/ps.subproj/IOPSKeys.h       $dest/ps

    # pwr_mgt: complete
    cp IOKitUser-907.100.13/pwr_mgt.subproj/IOPMKeys.h                                 $dest/pwr_mgt
    cp IOKitUser-907.100.13/pwr_mgt.subproj/IOPMLib.h                                  $dest/pwr_mgt
    cp ${xnu}/System/Library/Frameworks/IOKit.framework/Versions/A/Headers/pwr_mgt/*.h $dest/pwr_mgt

    # sbp2: complete
    cp IOFireWireSBP2-426.4.1/IOFireWireSBP2Lib/IOFireWireSBP2Lib.h $dest/sbp2

    # scsi: omitted for now

    # serial: complete
    cp IOSerialFamily-64.1.1/IOSerialFamily.kmodproj/IOSerialKeys.h $dest/serial
    cp IOSerialFamily-64.1.1/IOSerialFamily.kmodproj/ioss.h         $dest/serial

    # storage: complete
    # Needs ata subdirectory
    cp IOStorageFamily-172/IOAppleLabelScheme.h                                        $dest/storage
    cp IOStorageFamily-172/IOApplePartitionScheme.h                                    $dest/storage
    cp IOBDStorageFamily-14/IOBDBlockStorageDevice.h                                   $dest/storage
    cp IOBDStorageFamily-14/IOBDMedia.h                                                $dest/storage
    cp IOBDStorageFamily-14/IOBDMediaBSDClient.h                                       $dest/storage
    cp IOBDStorageFamily-14/IOBDTypes.h                                                $dest/storage
    cp IOStorageFamily-172/IOBlockStorageDevice.h                                      $dest/storage
    cp IOStorageFamily-172/IOBlockStorageDriver.h                                      $dest/storage
    cp IOCDStorageFamily-51/IOCDBlockStorageDevice.h                                   $dest/storage
    cp IOCDStorageFamily-51/IOCDMedia.h                                                $dest/storage
    cp IOCDStorageFamily-51/IOCDMediaBSDClient.h                                       $dest/storage
    cp IOCDStorageFamily-51/IOCDPartitionScheme.h                                      $dest/storage
    cp IOCDStorageFamily-51/IOCDTypes.h                                                $dest/storage
    cp IODVDStorageFamily-35/IODVDBlockStorageDevice.h                                 $dest/storage
    cp IODVDStorageFamily-35/IODVDMedia.h                                              $dest/storage
    cp IODVDStorageFamily-35/IODVDMediaBSDClient.h                                     $dest/storage
    cp IODVDStorageFamily-35/IODVDTypes.h                                              $dest/storage
    cp IOStorageFamily-172/IOFDiskPartitionScheme.h                                    $dest/storage
    cp IOStorageFamily-172/IOFilterScheme.h                                            $dest/storage
    cp IOFireWireSerialBusProtocolTransport-251.0.1/IOFireWireStorageCharacteristics.h $dest/storage
    cp IOStorageFamily-172/IOGUIDPartitionScheme.h                                     $dest/storage
    cp IOStorageFamily-172/IOMedia.h                                                   $dest/storage
    cp IOStorageFamily-172/IOMediaBSDClient.h                                          $dest/storage
    cp IOStorageFamily-172/IOPartitionScheme.h                                         $dest/storage
    cp IOStorageFamily-172/IOStorage.h                                                 $dest/storage
    cp IOStorageFamily-172/IOStorageCardCharacteristics.h                              $dest/storage
    cp IOStorageFamily-172/IOStorageDeviceCharacteristics.h                            $dest/storage
    cp IOStorageFamily-172/IOStorageProtocolCharacteristics.h                          $dest/storage

    # stream: missing altogether

    # usb: complete
    cp IOUSBFamily-630.4.5/IOUSBFamily/Headers/IOUSBLib.h            $dest/usb
    cp IOUSBFamily-630.4.5/IOUSBUserClient/Headers/IOUSBUserClient.h $dest/usb
    cp IOUSBFamily-560.4.2/IOUSBFamily/Headers/USB.h                 $dest/usb # This file is empty in 630.4.5!
    cp IOUSBFamily-630.4.5/IOUSBFamily/Headers/USBSpec.h             $dest/usb

    # video: missing altogether
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [ joelteon copumpkin ];
    platforms   = platforms.darwin;
    license     = licenses.apsl20;
  };
}
