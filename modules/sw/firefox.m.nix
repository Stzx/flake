{
  home =
    {
      lib,
      config,
      sysCfg,
      ...
    }:

    let
      inherit (lib) mkIf;

      profile = "firefox.${config.home.username}";
    in
    {
      config = mkIf config.programs.firefox.enable (
        lib.mkMerge [
          {
            programs.firefox = {
              policies = {
                AutofillAddressEnabled = false;
                AutofillCreditCardEnabled = false;

                DontCheckDefaultBrowser = true;
                StartDownloadsInTempDirectory = true;

                DisableTelemetry = true;
              };
              profiles."${profile}" = {
                search = {
                  default = "bing";
                  order = [
                    "bing"
                    "google"
                  ];
                  force = true;
                };
                settings = {
                  "dom.security.https_only_mode" = true;
                  "dom.security.https_only_mode_error_page_user_suggestions" = true;

                  "gfx.content.skia-font-cache-size" = 32;
                  "gfx.webrender.layer-compositor" = true;

                  # "layout.frame_rate" = 60;
                  "layout.spellcheckDefault" = 0;

                  "media.memory_cache_max_size" = 262144;
                  "media.memory_caches_combined_limit_kb" = 1048576;
                  "media.eme.enabled" = true;
                  "media.ffmpeg.vaapi.enabled" = true;

                  "media.webspeech.recognition.enable" = false;
                  "media.webspeech.synth.enabled" = false;

                  "image.cache.size" = 10485760;
                  "image.mem.decode_bytes_at_a_time" = 65536;

                  "browser.aboutConfig.showWarning" = false;

                  "browser.cache.disk.enable" = false;
                  "browser.cache.disk_cache_ssl" = false;
                  "browser.cache.memory.capacity" = 1048576;
                  "browser.cache.memory.max_entry_size" = 32768;

                  "browser.sessionstore.interval" = 300000;
                  "browser.bookmarks.max_backups" = 3;

                  "browser.contentblocking.category" = "standard";

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

                  "browser.urlbar.suggest.engines" = false;
                  "browser.urlbar.suggest.topsites" = false;
                  "browser.urlbar.suggest.trending" = false;
                  "browser.urlbar.suggest.weather" = false;
                  "browser.urlbar.suggest.yelp" = false;

                  "browser.preferences.moreFromMozilla" = false;

                  "browser.safebrowsing.downloads.enabled" = false;
                  "browser.safebrowsing.downloads.remote.enabled" = false;
                  "browser.safebrowsing.downloads.remote.block_potentially_unwanted" = false;
                  "browser.safebrowsing.downloads.remote.block_uncommon" = false;

                  "browser.download.useDownloadDir" = false;
                  "browser.download.manager.addToRecentDocs" = false;

                  "browser.display.document_color_use" = 0;
                  "browser.formfill.enable" = false;
                  "browser.region.update.enabled" = false;
                  "browser.shell.checkDefaultBrowser" = false;
                  "browser.tabs.inTitlebar" = 1;

                  "browser.vpn_promo.enabled" = false;

                  "browser.quitShortcut.disabled" = true;

                  "browser.ml.chat.enabled" = false;

                  # "network.dns.disableIPv6" = true;
                  "network.dns.disablePrefetch" = true;
                  "network.dns.disablePrefetchFromHTTPS" = true;

                  "network.trr.mode" = 5;
                  "network.predictor.enabled" = false;

                  "network.connectivity-service.enabled" = false;
                  "network.captive-portal-service.enabled" = false;

                  "sidebar.visibility" = "expand-on-hover";
                  "sidebar.position_start" = false;
                  "sidebar.main.tools" = "history,bookmarks";
                  "sidebar.verticalTabs" = true;

                  "privacy.partition.serviceWorkers" = true;

                  # PASSWORDS
                  "signon.autofillForms" = false;
                  "signon.rememberSignons" = false;
                  "signon.formlessCapture.enabled" = false;
                  "signon.firefoxRelay.feature" = "disabled";
                  "signon.generation.enabled" = false;
                  "signon.management.page.breach-alerts.enabled" = false;

                  "services.sync.log.appender.file.logOnError" = false;
                  "services.sync.log.appender.file.logOnSuccess" = false;

                  "extensions.formautofill.addresses.enabled" = false;
                  "extensions.formautofill.creditCards.enabled" = false;
                  "extensions.htmlaboutaddons.recommendations.enabled" = false;

                  "extensions.pocket.enabled" = false;

                  "devtools.debugger.skip-pausing" = true;
                  "devtools.aboutdebugging.showHiddenAddons" = true;

                  "app.normandy.enabled" = false;
                  "app.normandy.first_run" = false;

                  "pdfjs.defaultZoomValue" = "page-fit";
                  "pdfjs.enabledCache.state" = true;
                  "pdfjs.disableFontFace" = true;
                  "pdfjs.sidebarViewOnLoad" = 0;
                  "pdfjs.spreadModeOnLoad" = 0;

                  "full-screen-api.warning.timeout" = 0;

                  "trailhead.firstrun.branches" = "nofirstrun-empty";
                  "trailhead.firstrun.didSeeAboutWelcome" = true;

                  "toolkit.telemetry.enabled" = false;
                  "toolkit.telemetry.archive.enabled" = false;
                  "toolkit.telemetry.unified" = false;

                  "datareporting.usage.uploadEnabled" = false;
                  "datareporting.healthreport.uploadEnabled" = false;
                  "datareporting.policy.dataSubmissionEnabled" = false;
                };
              };
            };
          }

          (mkIf sysCfg.features.gpu.nvidia {
            programs.firefox.profiles."${profile}".settings = {
              # FIXME: https://github.com/elFarto/nvidia-vaapi-driver
              "gfx.x11-egl.force-enabled" = true;

              "widget.dmabuf.force-enabled" = true;
            };
          })
        ]
      );
    };
}
