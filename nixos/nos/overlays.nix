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
    swaySupport = false;
    upowerSupport = false;
    withMediaPlayer = false;
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

  fluent-gtk-theme = prev.fluent-gtk-theme.override {
    themeVariants = [
      "purple"
      "green"
    ];
    sizeVariants = [ "standard" ];
    tweaks = [ "blur" ];
  };

  bibata-cursors = prev.bibata-cursors.overrideAttrs {
    buildPhase = ''
      runHook preBuild

      ctgen configs/normal/x.build.toml -p x11 -d $bitmaps/Bibata-Modern-Classic -n 'Bibata-Modern-Classic' -c 'Black and rounded edge Bibata XCursors'
      ctgen configs/normal/x.build.toml -p x11 -d $bitmaps/Bibata-Modern-Ice -n 'Bibata-Modern-Ice' -c 'White and rounded edge Bibata XCursors'

      runHook postBuild
    '';
  };
})
