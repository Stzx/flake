final: prev: {
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
      rm -fv $out/lib/firmware/amdgpu/{\
      aldebaran,arcturus,\
      hainan,oland,pitcairn,tahiti,topaz,polaris,vega,fiji,tonga,stoney,carrizo,hawaii,bonaire,kabini,kaveri,mullins,banks_k_s,renoir,picasso,raven,verde,\
      navi10,navi12,navi14,\
      yellow_carp,vangogh,green_sardine,cyan_skillfish2,si58,\
      gc_9_4,sdma_4_4}*.bin

      rm -rfv $out/lib/firmware/radeon

      ${prevAttrs.postInstall or ""}
    '';
  });

  linuxPackages_xanmod = prev.linuxPackages_xanmod.extend (
    _: prevAttrs: {
      kernel = final.linuxManualConfig {
        inherit (prevAttrs.kernel) src version modDirVersion;

        configfile = ./core/kernel-configuration;
        allowImportFromDerivation = true;
        extraMeta = prevAttrs.kernel.meta;
      };
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
  };

  mpv = prev.mpv-unwrapped.wrapper {
    mpv = prev.mpv-unwrapped.override {
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
    youtubeSupport = false;
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
    withKeePassTouchID = false;
    withKeePassX11 = false;
    withKeePassYubiKey = false;
  };
}
