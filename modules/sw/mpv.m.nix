{
  home =
    {
      pkgs,
      lib,
      config,
      ...
    }:

    let
      inherit (pkgs) anime4k fetchurl;

      rifeVer = "rife-v4.25-lite";
      vsrVer = "r9_mod_v33";

      rife' = pkgs.linkFarm rifeVer [
        {
          name = "flownet.bin";
          path = fetchurl {
            url = "https://github.com/styler00dollar/VapourSynth-RIFE-ncnn-Vulkan/raw/refs/tags/${vsrVer}/models/${rifeVer}_ensembleFalse/flownet.bin";
            hash = "sha256-NQoV5GS+pa03jgbA+0OZbpCg01ZT1abva8mA2DJTj7c=";
          };
        }

        {
          name = "flownet.param";
          path = fetchurl {
            url = "https://github.com/styler00dollar/VapourSynth-RIFE-ncnn-Vulkan/raw/refs/tags/${vsrVer}/models/${rifeVer}_ensembleFalse/flownet.param";
            hash = "sha256-91DsZyPwWoAMj7B6wL81N+dBtv9/5hs4lOQHvRA3OmM=";
          };
        }
      ];

      librife = fetchurl {
        url = "https://github.com/styler00dollar/VapourSynth-RIFE-ncnn-Vulkan/releases/download/${vsrVer}/librife_linux_x86-64.so";
        hash = "sha256-l9EVslLVzRKt4a60Y7S5ZSm6xZxfIHPzs38X8OJyTAs=";
      };

      rife = pkgs.writeText "rife.vpy" ''
        from vapoursynth import core, RGBS, YUV420P8

        core.std.LoadPlugin(r"${librife}")

        clip = video_in

        clip = core.resize.Point(clip, format=RGBS, matrix_in_s="709")

        clip = core.rife.RIFE(clip, model_path=r"${rife'}", factor_num=5, factor_den=2, gpu_thread=4)

        clip = core.resize.Point(clip, format=YUV420P8, matrix_s="709")

        clip.set_output()
      '';
    in
    {
      config = lib.mkIf config.programs.mpv.enable {
        xdg.configFile = {
          "yt-dlp/config".text = "--cookies-from-browser Firefox";
          # "vapoursynth/vapoursynth.conf".text = ''
          #   UserPluginDir=
          # '';
        };

        programs.mpv = {
          bindings = {
            "CTRL+v" = ''cycle-values vo "gpu-next" "gpu" "dmabuf-wayland"'';
            "CTRL+f" = ''no-osd vf set "vapoursynth=${rife}"'';

            # curl -sL https://github.com/bloc97/Anime4K/raw/master/md/Template/GLSL_Mac_Linux_High-end/input.conf | grep '^CTRL' | sed -r -e '/^$/d' -e 's|~~/shaders/|${anime4k}/|g' -e "s| |\" = ''|" -e "s|$|'';|"
            # curl -sL https://github.com/bloc97/Anime4K/raw/master/md/Template/GLSL_Mac_Linux_Low-end/input.conf | grep '^CTRL' | sed -r -e '/^$/d' -e 's|~~/shaders/|${anime4k}/|g' -e "s| |\" = ''|" -e "s|$|'';|"
            "CTRL+1" =
              ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_VL.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode A (HQ)"'';
            "CTRL+2" =
              ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_VL.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode B (HQ)"'';
            "CTRL+3" =
              ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode C (HQ)"'';
            "CTRL+4" =
              ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_VL.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${anime4k}/Anime4K_Restore_CNN_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode A+A (HQ)"'';
            "CTRL+5" =
              ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_VL.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode B+B (HQ)"'';
            "CTRL+6" =
              ''no-osd change-list glsl-shaders set "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Restore_CNN_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode C+A (HQ)"'';

            "CTRL+0" = ''no-osd change-list glsl-shaders clr ""; no-osd vf clr ""; show-text "cleared !"'';
          };
          config = {
            osc = false;
            border = false;

            vo = "gpu-next,gpu,dmabuf-wayland";
            hwdec = "vulkan,vaapi";
            video-sync = "display-resample";
            interpolation = false;
            icc-profile-auto = true;
            blend-subtitles = "video";

            fs = true;
            mute = true;
            keepaspect = true;

            alang = "chi,zh,ja,en";
            audio-file-auto = "exact";

            slang = "zh-CN,zh-Hans,cmn-Hans,chi,chs,sc,zh,en";
            sub-auto = "fuzzy";
          };
          profiles = {
            "unscaled" = {
              profile-cond = "p['video-params/h'] <= 1080";
              profile = "high-quality";
              video-unscaled = true;
            };
          };
          defaultProfiles = [ "high-quality" ];
          scripts = with pkgs.mpvScripts; [
            modernx
            mpris
          ];
          scriptOpts.osc.showonpause = false;
        };
      };
    };
}
