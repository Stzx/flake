{
  lib,
  wmCfg,
  ...
}:

(final': prev': {
  linuxManualConfig = prev'.linuxManualConfig.override rec {
    # TRACK:
    # - https://github.com/NixOS/nixpkgs/issues/142901
    # - https://github.com/NixOS/nixpkgs/issues/49894
    stdenv = prev'.ccacheStdenv.override {
      stdenv = final'.overrideCC prev'.clangStdenv (
        prev'.clangStdenv.cc.override {
          inherit (final'.llvmPackages) bintools;
        }
      );
    };
    buildPackages = final'.buildPackages // {
      inherit stdenv;
    };
  };

  # https://wiki.gentoo.org/wiki/AMDGPU#Firmware_blobs_for_a_known_card_model
  linux-firmware = prev'.linux-firmware.overrideAttrs {
    postInstall = ''
      find $out/lib/firmware/amdgpu -type f ! \( \
      -name 'sienna_cichlid_*.bin' \
      -o -name 'beige_goby_dmcub.bin' \
      -o -name 'beige_goby_vcn.bin' \
      \) -exec truncate -s 0 {} +

      # dimgrey_cavefish_dmcub.bin, dimgrey_cavefish_vcn.bin
      # it will still point to `beige_goby`, causing the file to be copied.
    '';
  };

  linuxPackages_xanmod_stable = prev'.linuxPackages_xanmod_stable.extend (
    _: prev: {
      kernel = final'.linuxManualConfig {
        inherit (prev.kernel) src version modDirVersion;
        allowImportFromDerivation = true;

        configfile = ./core/kernel-configuration;
        extraMakeFlags = [
          "LLVM=1"
        ];
      };
    }
  );

  niri = prev'.niri.overrideAttrs (
    _: prev:
    let
      env' = prev.env or { };
      NIX_RUSTFLAGS' = env'.NIX_RUSTFLAGS or [ ];
    in
    {
      env = env' // {
        NIX_RUSTFLAGS = builtins.toString ([ NIX_RUSTFLAGS' ] ++ [ "-C target-cpu=x86-64-v3" ]);
      };
    }
  );

  libvirt = prev'.libvirt.override {
    enableXen = false;
    enableZfs = false;
  };

  qt6Packages = prev'.qt6Packages.overrideScope (
    fs: ps: rec {
      fcitx5-configtool = ps.fcitx5-configtool.override { kcmSupport = wmCfg.isKDE; };

      fcitx5-chinese-addons =
        let
          cmb = final'.lib.cmakeBool;

          fca' = ps.fcitx5-chinese-addons.override {
            curl = null;
            opencc = null;
            qtwebengine = null;
          };
        in
        fca'.overrideAttrs (
          _: prev:
          assert prev.version == "5.1.10"; # wait fix
          {
            # FIXME: https://github.com/fcitx/fcitx5-chinese-addons/issues/233
            postPatch = ''
              substituteInPlace test/addon/CMakeLists.txt \
                --replace-fail '    cloudpinyin.conf.in-fmt' ' '
            '';

            cmakeFlags = (prev.cmakeFlags or [ ]) ++ [
              (cmb "ENABLE_BROWSER" false)
              (cmb "ENABLE_CLOUDPINYIN" false)
              (cmb "ENABLE_OPENCC" false)
            ];
          }
        );

      fcitx5-with-addons = ps.fcitx5-with-addons.override { inherit fcitx5-configtool; };
    }
  );

  waybar = prev'.waybar.override {
    evdevSupport = false;
    cavaSupport = false;
    jackSupport = false;
    mpdSupport = false;
    mprisSupport = false;
    rfkillSupport = false;
    sndioSupport = false;
    upowerSupport = false;
    withMediaPlayer = false;

    niriSupport = wmCfg.isNiri;
  };

  mpv-unwrapped = prev'.mpv-unwrapped.override {
    x11Support = false;
    sdl2Support = false;
    cacaSupport = false;
    vdpauSupport = false;

    dvbinSupport = false;

    alsaSupport = false;
    pulseSupport = false;
    openalSupport = false;

    javascriptSupport = false;

    vapoursynth = final'.vapoursynth.withPlugins [ final'.vs-rife-ncnn-vulkan ];
    vapoursynthSupport = true;
  };

  qbittorrent = prev'.qbittorrent.override {
    trackerSearch = false;
    webuiSupport = false;
  };

  keepassxc = prev'.keepassxc.override {
    withKeePassBrowser = false;
    withKeePassBrowserPasskeys = false;
    withKeePassFDOSecrets = false;
    withKeePassNetworking = false;
    withKeePassSSHAgent = false;
    withKeePassX11 = false;
  };
})
