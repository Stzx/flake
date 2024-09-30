{
  lib,
  config,
  osConfig,
  ...
}:

let
  profile = "firefox.${config.home.username}";

  useNvidia = osConfig.features.gpu.nvidia;
in
{
  programs.firefox = {
    profiles.${profile} = {
      search = {
        default = "Bing";
        order = [
          "Bing"
          "Google"
          "DuckDuckGo"
        ];
        force = true;
      };
      settings =
        {
          "browser.aboutConfig.showWarning" = false;

          "browser.cache.memory.capacity" = 1048576;
          "browser.cache.disk.enable" = false;
          "browser.cache.disk_cache_ssl" = false;

          "browser.sessionstore.interval" = 900000;

          "browser.contentblocking.category" = "strict";

          "browser.newtabpage.enabled" = false;
          "browser.startup.homepage" = "about:blank";
          "browser.toolbars.bookmarks.visibility" = "newtab";

          "browser.newtabpage.activity-stream.telemetry" = false;
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.newtabpage.activity-stream.showSearch" = false;
          "browser.newtabpage.activity-stream.feeds.topsites" = false;
          "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
          "browser.newtabpage.activity-stream.feeds.snippets" = false;
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;

          "browser.urlbar.suggest.topsites" = false;
          "browser.urlbar.suggest.engines" = false;

          "browser.preferences.moreFromMozilla" = false;

          "browser.safebrowsing.downloads.enabled" = false;
          "browser.safebrowsing.downloads.remote.enabled" = false;
          "browser.safebrowsing.downloads.remote.block_potentially_unwanted" = false;
          "browser.safebrowsing.downloads.remote.block_uncommon" = false;

          "browser.download.useDownloadDir" = true;
          "browser.download.manager.addToRecentDocs" = false;

          "browser.region.update.enabled" = false;
          "browser.shell.checkDefaultBrowser" = false;
          "browser.tabs.inTitlebar" = 1;

          "browser.vpn_promo.enabled" = false;

          "network.dns.disableIPv6" = true;
          "network.trr.mode" = 5;
          "network.predictor.enabled" = false;
          "network.captive-portal-service.enabled" = false;

          "privacy.partition.serviceWorkers" = true;

          "signon.autofillForms" = false;
          "signon.rememberSignons" = false;
          "signon.formlessCapture.enabled" = false;

          "extensions.htmlaboutaddons.recommendations.enabled" = false;

          "extensions.pocket.enabled" = false;

          "devtools.debugger.skip-pausing" = true;
          "devtools.aboutdebugging.showHiddenAddons" = true;

          "app.normandy.enabled" = false;
          "app.normandy.first_run" = false;

          "pdfjs.sidebarViewOnLoad" = 0;
          "pdfjs.spreadModeOnLoad" = 0;
          "pdfjs.defaultZoomValue" = "page-fit";
          "pdfjs.enabledCache.state" = true;

          "datareporting.policy.dataSubmissionEnabled" = false;
          "datareporting.healthreport.uploadEnabled" = false;

          "full-screen-api.warning.timeout" = 0;

          "layout.frame_rate" = 144;
          "layout.spellcheckDefault" = 0;

          "trailhead.firstrun.branches" = "nofirstrun-empty";
          "trailhead.firstrun.didSeeAboutWelcome" = true;

          "media.eme.enabled" = true;
          "media.ffmpeg.vaapi.enabled" = true;

          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.reportingpolicy.firstRun" = false;
        }
        // lib.optionalAttrs useNvidia {
          # FIXME: https://github.com/elFarto/nvidia-vaapi-driver
          "gfx.x11-egl.force-enabled" = true;

          "widget.dmabuf.force-enabled" = true;
        };
    };
  };
}
