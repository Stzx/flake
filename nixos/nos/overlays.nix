final: prev: {
  waybar = prev.waybar.override (_: {
    cavaSupport = false;
    jackSupport = false;
    mpdSupport = false;
    mprisSupport = false;
    rfkillSupport = false;
    sndioSupport = false;
    swaySupport = false;
    upowerSupport = false;
    withMediaPlayer = false;
  });
}
