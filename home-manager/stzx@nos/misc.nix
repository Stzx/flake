{ ... }:

{
  programs.bash = {
    enable = true;
    package = null;
    historyFileSize = 0;
    historySize = null;
  };

  programs.git = {
    userName = "Stzx";
    userEmail = "silence.m@hotmail.com";
    delta.enable = true;
  };

  programs.waybar.settings.mainBar.output = "DP-1";

  programs.niri.settings = {
    input.touchpad.enable = false;
    outputs = {
      "DP-1".variable-refresh-rate = "on-demand";
      "DP-2".transform.rotation = 90;
    };
    window-rules = [
      {
        matches = [
          { app-id = "Waydroid"; }
          { app-id = "calibre-ebook-viewer"; }
        ];

        open-on-output = "DP-2";
        open-fullscreen = true;
      }
    ];
  };
}
