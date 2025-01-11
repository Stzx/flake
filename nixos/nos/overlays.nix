final: prev: {
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
      vdpauSupport = false;
      vapoursynthSupport = false;
      javascriptSupport = false;
      alsaSupport = false;
      pulseSupport = false;
      openalSupport = false;
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
