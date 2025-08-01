final': prev': {
  # _ = prev'._.overrideAttrs (
  #   _: prev:
  #   let
  #     env' = prev.env or { };
  #     NIX_CFLAGS_COMPILE' = env'.NIX_CFLAGS_COMPILE or [ ];
  #   in
  #   {
  #     env = env' // {
  #       NIX_CFLAGS_COMPILE = builtins.toString ([ NIX_CFLAGS_COMPILE' ] ++ [ "-march=x86-64-v3" ]);
  #     };
  #   }
  # );

  _7zz = final'.symlinkJoin {
    name = "7z";
    paths = [ prev'._7zz ];
    postBuild = ''
      ln -s ${prev'._7zz}/bin/7zz $out/bin/7z
    '';
  };

  wrapFirefox = prev'.wrapFirefox.override {
    config = rec {
      firefox = {
        enableQuakeLive = false;
        speechSynthesisSupport = false;
      };
      thunderbird = firefox;
    };
  };

  mpd = prev'.mpdWithFeatures {
    features = [
      "io_uring"

      "alsa"
      "pipewire"

      "soxr"

      # "audiofile" # wav or aiff
      # "faad"
      "ffmpeg"
      "flac"
      # "mad" # mp3
      # "mpg123" # mp1 or mp2 or mp3
      # vorbis" # ogg

      "id3tag"

      "dbus"
      "expat"
      "icu"
      "pcre"
      "sqlite"
      "syslog"
      "systemd"
    ];
  };

  jetbrains =
    let
      vmopts = ''
        -Xms3072m
        -Xmx6144m
        -XX:ReservedCodeCacheSize=1024m
        -XX:MaxMetaspaceSize=1024m
      '';
    in
    prev'.jetbrains
    // {
      idea-community = prev'.jetbrains.idea-community.override { inherit vmopts; };
      rust-rover = prev'.jetbrains.rust-rover.override { inherit vmopts; };
    };

  fluent-gtk-theme = prev'.fluent-gtk-theme.override {
    themeVariants = [
      "purple"
      "green"
    ];
    sizeVariants = [ "standard" ];
    tweaks = [ "blur" ];
  };

  bibata-cursors = prev'.bibata-cursors.overrideAttrs {
    buildPhase = ''
      runHook preBuild

      ctgen configs/normal/x.build.toml -p x11 -d $bitmaps/Bibata-Modern-Classic -n 'Bibata-Modern-Classic' -c 'Black and rounded edge Bibata XCursors'
      ctgen configs/normal/x.build.toml -p x11 -d $bitmaps/Bibata-Modern-Ice -n 'Bibata-Modern-Ice' -c 'White and rounded edge Bibata XCursors'

      runHook postBuild
    '';
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
  fuse-avfs = prev'.avfs.overrideAttrs (
    _: prevAttrs: {
      pname = "fuse-avfs"; # I prefer the package name fuse-avfs.
      buildInputs = (prevAttrs.buildInputs or [ ]) ++ [ final'.zstd ];
      configureFlags = (prevAttrs.configureFlags or [ ]) ++ [ "--with-zstd=yes" ];
    }
  );
}
