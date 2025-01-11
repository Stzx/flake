{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (lib) mkIf isKDE;

  kwriteConfig = "${pkgs.kdePackages.kconfig}/bin/kwriteconfig6";

  directory = "${config.home.homeDirectory}/.config";

  mkCli = rc: cliFnList: lib.concatLines (lib.forEach cliFnList (cliFn: cliFn "${directory}/${rc}"));

  # SET/LOCK: [ GROUPS ] [ [ KEY VALUE ] ... ]
  # DEL: [ GROUPS ] [ KEYS ]
  mkArgs =
    {
      groups,
      kv,
      del ? false,
      lock ? false,
    }:
    lib.forEach kv (
      item:
      assert !(del && lock);
      let
        _groups = lib.concatMapStringsSep " " (group: "--group '${group}'") groups;
        _value = if del then "--delete" else "'${builtins.elemAt item 1}'";
      in
      if lock then
        (
          let
            key = builtins.elemAt item 0;
            keyMark = "#_${key}_#";
          in
          [
            (f: "${kwriteConfig} --file ${f} ${_groups} --key '${key}' --delete")
            (f: "${kwriteConfig} --file ${f} ${_groups} --key '${keyMark}' ${_value}")
            (f: "${pkgs.gnused}/bin/sed -i 's/${keyMark}/${key}[$i]/g' ${f}")
          ]
        )
      else
        (
          let
            key = if del then item else builtins.elemAt item 0;
          in
          [
            (f: "${kwriteConfig} --file ${f} ${_groups} --key '${key}' ${_value}")
          ]
        )
    );

  set = groups: kv: mkArgs { inherit groups kv; };

  _del =
    groups: kv:
    mkArgs {
      inherit groups kv;
      del = true;
    };

  lock =
    groups: kv:
    mkArgs {
      inherit groups kv;
      lock = true;
    };

  settings = {
    "kded5rc" = [
      (lock
        [ "Module-colorcorrectlocationupdater" ]
        [
          [
            "autoload"
            "false"
          ]
        ]
      )
      (lock
        [ "Module-freespacenotifier" ]
        [
          [
            "autoload"
            "false"
          ]
        ]
      )
      (lock
        [ "Module-kded_touchpad" ]
        [
          [
            "autoload"
            "false"
          ]
        ]
      )
      (lock
        [ "Module-plasma_accentcolor_service" ]
        [
          [
            "autoload"
            "false"
          ]
        ]
      )
    ];

    "kwinrc" = [
      (set
        [ "Desktops" ]
        [
          [
            "Number"
            "2"
          ]
          [
            "Name_1"
            "Tom"
          ]
          [
            "Name_2"
            "Jerry"
          ]
        ]
      )
      (lock
        [ "TabBox" ]
        [
          [
            "ShowTabBox"
            "false"
          ]
          [
            "SwitchingMode"
            "1"
          ]
        ]
      )
      (lock
        [ "Plugins" ]
        [
          [
            "slidebackEnabled"
            "true"
          ]
          [
            "zoomEnabled"
            "false"
          ]
          [
            "tileseditorEnabled"
            "false"
          ]
        ]
      )
      (lock
        [ "Input" ]
        [
          [
            "TabletMode"
            "off"
          ]
        ]
      )
    ];

    "kdeglobals" =
      let
        default = "Sarasa UI SC,10,-1,5,50,0,0,0,0,0";
        mono = "Sarasa Mono SC,10,-1,5,50,0,0,0,0,0";
      in
      [
        (lock
          [ "General" ]
          [
            [
              "fixed"
              mono
            ]
            [
              "font"
              default
            ]
            [
              "menuFont"
              default
            ]
            [
              "smallestReadableFont"
              default
            ]
            [
              "toolBarFont"
              default
            ]
          ]
        )
        (lock
          [ "WM" ]
          [
            [
              "activeFont"
              default
            ]
          ]
        )
      ];

    "powerdevilrc" = [
      (lock
        [
          "AC"
          "SuspendAndShutdown"
        ]
        [
          [
            "AutoSuspendAction"
            "0"
          ]
        ]
      )
    ];

    "ksplashrc" = [
      (lock
        [ "KSplash" ]
        [
          [
            "Engine"
            "None"
          ]
          [
            "Theme"
            "None"
          ]
        ]
      )
    ];

    "kwalletrc" = [
      (lock
        [ "Wallet" ]
        [
          [
            "Enabled"
            "false"
          ]
        ]
      )
    ];

    "kcminputrc" = [
      (lock
        [ "Keyboard" ]
        [
          [
            "NumLock"
            "0"
          ]
          [
            "RepeatDelay"
            "500"
          ]
        ]
      )
    ];

    # Theme
    "breezerc" = [
      (lock
        [ "Common" ]
        [
          [
            "OutlineCloseButton"
            "true"
          ]
        ]
      )
    ];

    # Search & Index
    "baloofilerc" = [
      (lock
        [ "General" ]
        [
          [
            "only basic indexing"
            "true"
          ]
        ]
      )
    ];

    "krunnerrc" = [
      (lock
        [ "Plugins" ]
        [
          [
            "helprunnerEnabled"
            "false"
          ]
          [
            "krunner_appstreamEnabled"
            "false"
          ]
          [
            "krunner_bookmarksrunnerEnabled"
            "false"
          ]
          [
            "krunner_dictionaryEnabled"
            "false"
          ]
          [
            "krunner_katesessionsEnabled"
            "false"
          ]
          [
            "krunner_killEnabled"
            "false"
          ]
          [
            "krunner_konsoleprofilesEnabled"
            "false"
          ]
          [
            "krunner_placesrunnerEnabled"
            "false"
          ]
          [
            "krunner_powerdevilEnabled"
            "false"
          ]
          [
            "krunner_recentdocumentsEnabled"
            "false"
          ]
          [
            "krunner_spellcheckEnabled"
            "false"
          ]
          [
            "krunner_webshortcutsEnabled"
            "false"
          ]
          [
            "locationsEnabled"
            "false"
          ]
          [
            "org.kde.datetimeEnabled"
            "false"
          ]
        ]
      )
    ];

    # Lockscreen
    "kscreenlockerrc" =
      let
        wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/IceCold/";
      in
      [
        (set
          [
            "Greeter"
            "Wallpaper"
            "org.kde.image"
            "General"
          ]
          [
            [
              "Image"
              wallpaper
            ]
            [
              "PreviewImage"
              wallpaper
            ]
          ]
        )
      ];

    # History
    "kactivitymanagerd-pluginsrc" = [
      (lock
        [ "Plugin-org.kde.ActivityManager.Resources.Scoring" ]
        [
          [
            "keep-history-for"
            "1"
          ]
          [
            "what-to-remember"
            "2"
          ]
        ]
      )
    ];

    # Application
    "systemsettingsrc" = [
      (lock
        [ "systemsettings_sidebar_mode" ]
        [
          [
            "HighlightNonDefaultSettings"
            "true"
          ]
        ]
      )
    ];

    "dolphinrc" = [
      (lock
        [ "General" ]
        [
          [
            "ModifiedStartupSettings"
            "false"
          ]
          [
            "OpenExternallyCalledFolderInNewTab"
            "true"
          ]
          [
            "ShowFullPath"
            "true"
          ]
          [
            "SplitView"
            "true"
          ]
        ]
      )
      (lock
        [ "PlacesPanel" ]
        [
          [
            "IconSize"
            "32"
          ]
        ]
      )
      (lock
        [ "KFileDialog Settings" ]
        [
          [
            "IconSize"
            "32"
          ]
        ]
      )
      (lock
        [ "PreviewSettings" ]
        [
          [
            "Plugins"
            "appimagethumbnail,windowsimagethumbnail,windowsexethumbnail,svgthumbnail,cursorthumbnail"
          ]
        ]
      )
    ];

    "kservicemenurc" = [
      (lock
        [ "Show" ]
        [
          [
            "makefileactions"
            "true"
          ]
          [
            "wallpaperfileitemaction"
            "true"
          ]
        ]
      )
    ];
  };

  ked-init-commands = pkgs.writeShellScriptBin "kde-init" (
    lib.concatLines (lib.mapAttrsToList (rc: cliFnList: mkCli rc (lib.flatten cliFnList)) settings)
  );
in
mkIf isKDE {
  home.packages = [ ked-init-commands ];

  programs.zsh.shellAliases.kwin-dbg = "qdbus org.kde.KWin /KWin org.kde.KWin.showDebugConsole";
}
