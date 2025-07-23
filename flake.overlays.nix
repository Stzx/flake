final': prev': {
  _7zz = prev'._7zz.overrideAttrs (
    _: prev: {
      postInstall = ''
        ${prev.postInstall or ""}

        ln -s $out/bin/7zz $out/bin/7z
      '';
    }
  );

  firefox = prev'.firefox.override { cfg.speechSynthesisSupport = false; };

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
}
