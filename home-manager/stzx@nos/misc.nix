{
  pkgs,
  ...
}:

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

  home.packages = [ pkgs.xwayland-satellite-stable ];

  programs.niri.settings = {
    spawn-at-startup = [
      {
        command = [
          "xwayland-satellite"
          "-rootless"
        ];
      }
    ];
    environment = {
      DISPLAY = ":0";
    };
    input.touchpad.enable = false;
    outputs = {
      "DP-1".variable-refresh-rate = true;
      "DP-2".transform.rotation = 90;
    };
    window-rules = [
      {
        matches = [
          { app-id = "^Waydroid$"; }
          { app-id = "^calibre-ebook-viewer$"; }
        ];

        open-on-output = "DP-2";
      }
    ];
  };
}
