{ lib, ... }:

(final: prev: {
  linuxManualConfig = prev.linuxManualConfig.override {
    # FIXME: https://github.com/NixOS/nixpkgs/issues/49894
    # see https://github.com/NixOS/nixpkgs/issues/142901
    # stdenv = with pkgs; overrideCC clangStdenv (
    #   clangStdenv.cc.override {
    #     inherit (llvmPackages) bintools;
    #     # LTO: override bintools sharedLibraryLoader = null;
    #   }
    # );
    # LTO: extraMakeFlags = [ "LLVM=1" ];

    stdenv = final.ccacheStdenv;
    buildPackages = final.buildPackages // {
      stdenv = final.ccacheStdenv;
    };
  };

  linux-firmware = prev.linux-firmware.overrideAttrs (prevAttrs: {
    postInstall = ''
      find $out/lib/firmware/amdgpu -type f ! \( \
      -name 'sienna_cichlid_*.bin' \
      -o -name 'beige_goby_dmcub.bin' \
      -o -name 'beige_goby_vcn.bin' \
      \) -exec truncate -s 0 {} +

      # dimgrey_cavefish_dmcub.bin, dimgrey_cavefish_vcn.bin
      # it will still point to `beige_goby`, causing the file to be copied.
    '';
  });

  linuxPackages_xanmod = prev.linuxPackages_xanmod.extend (
    _: prevAttrs:
    let
      kernel' = final.linuxManualConfig {
        inherit (prevAttrs.kernel) src version modDirVersion;

        configfile = ./core/kernel-configuration;
        allowImportFromDerivation = true;
        extraMeta = prevAttrs.kernel.meta;
      };
    in
    {
      kernel = kernel'.overrideAttrs (
        _: prevAttrs_: {
          preConfigure = ''
            ${prevAttrs_.preConfigure or ""}

            export CCACHE_SLOPPINESS=random_seed
          '';
        }
      );
    }
  );

  waybar = prev.waybar.override {
    cavaSupport = false;
    jackSupport = false;
    mpdSupport = false;
    mprisSupport = false;
    rfkillSupport = false;
    sndioSupport = false;
    upowerSupport = false;
    withMediaPlayer = false;

    swaySupport = false;
    hyprlandSupport = lib.isHyprland;
    niriSupport = lib.isNiri;
  };

  mpv-unwrapped = prev.mpv-unwrapped.override {
    x11Support = false;
    sdl2Support = false;
    cacaSupport = false;
    vdpauSupport = false;

    alsaSupport = false;
    pulseSupport = false;
    openalSupport = false;

    vapoursynthSupport = false;
    javascriptSupport = false;
  };

  qbittorrent = prev.qbittorrent.override {
    trackerSearch = false;
    webuiSupport = false;
  };

  keepassxc = prev.keepassxc.override {
    withKeePassBrowser = false;
    withKeePassBrowserPasskeys = false;
    withKeePassFDOSecrets = false;
    withKeePassNetworking = false;
    withKeePassSSHAgent = false;
    withKeePassX11 = false;
    withKeePassYubiKey = false;
  };

  # I haven't found anyone encountering a similar error in nixpkgs issues.
  # It's strange. I fixed it myself.
  #
  # Module libatomic.so.1 without build-id.
  # Module libfuse.so.2 without build-id.
  # Stack trace of thread 416633:
  #0  0x000077d2dbf78a5d __strlen_avx2 (libc.so.6 + 0x178a5d)
  #1  0x0000000000409ae4 copy_exts (/nix/store/gcwvf8v46mkqdr2ndbkxmbphzh1b9fc0-avfs-1.2.0/bin/avfsd + 0x9ae4)
  #2  0x000000000041a452 av_init_filt (/nix/store/gcwvf8v46mkqdr2ndbkxmbphzh1b9fc0-avfs-1.2.0/bin/avfsd + 0x1a452)
  #3  0x0000000000414c04 av_init_module_uzstde (/nix/store/gcwvf8v46mkqdr2ndbkxmbphzh1b9fc0-avfs-1.2.0/bin/avfsd + 0x14c04)
  #4  0x000000000040841f init (/nix/store/gcwvf8v46mkqdr2ndbkxmbphzh1b9fc0-avfs-1.2.0/bin/avfsd + 0x841f)
  #5  0x0000000000403fbb open_path (/nix/store/gcwvf8v46mkqdr2ndbkxmbphzh1b9fc0-avfs-1.2.0/bin/avfsd + 0x3fbb)
  #6  0x0000000000403e29 avfsd_getattr (/nix/store/gcwvf8v46mkqdr2ndbkxmbphzh1b9fc0-avfs-1.2.0/bin/avfsd + 0x3e29)
  #7  0x000077d2dc134505 lookup_path (libfuse.so.2 + 0xd505)
  #8  0x000077d2dc1347aa fuse_lib_lookup (libfuse.so.2 + 0xd7aa)
  #9  0x000077d2dc140e6f fuse_ll_process_buf (libfuse.so.2 + 0x19e6f)
  #10 0x000077d2dc13dac2 fuse_do_work (libfuse.so.2 + 0x16ac2)
  #11 0x000077d2dbe97e63 start_thread (libc.so.6 + 0x97e63)
  #12 0x000077d2dbf1bdbc __clone3 (libc.so.6 + 0x11bdbc)
  fuse-avfs = prev.avfs.overrideAttrs (
    _: prevAttrs: {
      pname = "fuse-avfs"; # I prefer the package name fuse-avfs.
      buildInputs = (prevAttrs.buildInputs or [ ]) ++ [ final.zstd ];
      configureFlags = (prevAttrs.configureFlags or [ ]) ++ [ "--with-zstd=yes" ];
    }
  );
})
