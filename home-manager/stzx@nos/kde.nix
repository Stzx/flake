{ config, lib, pkgs, ... }:

let
  cfg = config.want;

  command = "${pkgs.plasma5Packages.kconfig}/bin/kwriteconfig5";

  directory = "${config.home.homeDirectory}/.config";

  mkCli = rc: args: lib.concatLines (lib.forEach args (arg:
    "${command} --file ${directory}/${rc} ${arg}"
  ));

  mkArgs = { groups, kv, onlyKey ? false }: lib.forEach kv (item:
    let
      key = if onlyKey then item else builtins.elemAt item 0;
      value = if onlyKey then "--delete" else builtins.elemAt item 1;
    in
    "${lib.concatMapStringsSep " " (g: "--group '${g}'") groups} --key ${key} '${value}'"
  );

  set = groups: kv: mkArgs { inherit groups kv; };

  del = groups: kv: mkArgs { inherit groups kv; onlyKey = true; };

  settings = {

    "kded5rc" = [
      (set [ "Module-freespacenotifier" ] [ [ "autoload" "false" ] ])
      (set [ "Module-networkstatus" ] [ [ "autoload" "false" ] ])
      (set [ "Module-plasma_accentcolor_service" ] [ [ "autoload" "false" ] ])
      (set [ "Module-proxyscout" ] [ [ "autoload" "false" ] ])
      (set [ "Module-colorcorrectlocationupdater" ] [ [ "autoload" "false" ] ])
      (set [ "Module-kded_touchpad" ] [ [ "autoload" "false" ] ])
      (set [ "Module-ksysguard" ] [ [ "autoload" "false" ] ])
    ];

    "kwinrc" = [
      (set [ "Input" ] [ [ "TabletMode" "off" ] ])
      (set [ "Plugins" ] [
        [ "zoomEnabled" "false" ]
        [ "blurEnabled" "false" ]
        [ "overviewEnabled" "false" ]
        [ "tileseditorEnabled" "false" ]
      ])
      (set [ "Desktops" ] [
        [ "Number" "2" ]
        [ "Name_1" "Tom" ]
        [ "Name_2" "Jerry" ]
      ])
    ];

    "kdeglobals" =
      let
        default = "Noto Sans,10,-1,5,50,0,0,0,0,0";
        mono = "Noto Sans Mono,10,-1,5,50,0,0,0,0,0";
      in
      [
        (set [ "General" ] [
          [ "fixed" mono ]
          [ "font" default ]
          [ "menuFont" default ]
          [ "smallestReadableFont" default ]
          [ "toolBarFont" default ]
        ])
        (set [ "WM" ] [ [ "activeFont" default ] ])
      ];

    "kdeglobalsrc" = [
      (set [ "General" ] [ [ "UseSystemBell" "true" ] ])
    ] ++ (lib.optional cfg.kitty (set [ "General" ] [
      [ "TerminalApplication" "kitty" ]
      [ "TerminalApplicationService" "kitty.desktop" ]
    ])) ++ (lib.optional cfg.alacritty (set [ "General" ] [
      [ "TerminalApplication" "alacritty" ]
      [ "TerminalApplicationService" "Alacritty.desktop" ]
    ]));

    "systemsettingsrc" = [
      (set [ "systemsettings_sidebar_mode" ] [ [ "HighlightNonDefaultSettings" "true" ] ])
    ];

    "powermanagementprofilesrc" = [
      (del [ "AC" "SuspendSession" ] [ "idleTime" "suspendThenHibernate" "suspendType" ])
    ];

    "ksplashrc" = [
      (set [ "KSplash" ] [
        [ "Engine" "None" ]
        [ "Theme" "None" ]
      ])
    ];

    "kactivitymanagerd-pluginsrc" = [
      (set [ "Plugin-org.kde.ActivityManager.Resources.Scoring" ] [ [ "what-to-remember" "1" ] ])
    ];

    "kactivitymanagerdrc" = [
      (set [ "Plugins" ] [ [ "org.kde.ActivityManager.ResourceScoringEnabled" "false" ] ])
    ];

    "kwalletrc" = [
      (set [ "Wallet" ] [ [ "Enabled" "false" ] ])
    ];

    "kcminputrc" = [
      (set [ "Keyboard" ] [ [ "NumLock" "0" ] ])
    ];

    "breezerc" = [
      (set [ "Common" ] [
        [ "ShadowSize" "ShadowSmall" ]
        [ "ShadowStrength" "128" ]
      ])
      (set [ "Style" ] [ [ "MenuOpacity" "75" ] ])
    ];

    "dolphinrc" = [
      (set [ "PlacesPanel" ] [ [ "IconSize" "32" ] ])
      (set [ "DetailsMode" ] [ [ "IconSize" "32" ] ])
      (set [ "PreviewSettings" ] [ [ "Plugins" "svgthumbnail" ] ])
    ];
  };

  commands = (lib.concatLines (lib.mapAttrsToList
    (rc: args: mkCli rc (lib.flatten args))
    settings
  ));
in
{
  home.activation.kdeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] commands;

  programs.zsh.shellAliases.kwin-dbg = "qdbus org.kde.KWin /KWin org.kde.KWin.showDebugConsole";
}
