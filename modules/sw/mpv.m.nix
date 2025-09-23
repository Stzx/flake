{
  home =
    {
      pkgs,
      lib,
      config,
      sysCfg,
      ...
    }:

    let
      inherit (pkgs) anime4k;

      vpy = "${sysCfg.environment.sessionVariables.__FLAKE}/dots/rife.vpy";

      glslPrefix = "no-osd change-list glsl-shaders set";
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
            "CTRL+f" =
              ''set hr-seek-framedrop no; vf set "vapoursynth=${config.lib.file.mkOutOfStoreSymlink vpy}"'';

            # curl -sL https://github.com/bloc97/Anime4K/raw/master/md/Template/GLSL_Mac_Linux_High-end/input.conf | grep '^CTRL' | sed -r -e '/^$/d' -e 's|~~/shaders/|${anime4k}/|g' -e "s| |\" = ''|" -e "s|$|'';|"
            # curl -sL https://github.com/bloc97/Anime4K/raw/master/md/Template/GLSL_Mac_Linux_Low-end/input.conf | grep '^CTRL' | sed -r -e '/^$/d' -e 's|~~/shaders/|${anime4k}/|g' -e "s| |\" = ''|" -e "s|$|'';|"
            "CTRL+1" =
              ''${glslPrefix} "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_VL.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode A (HQ)"'';
            "CTRL+2" =
              ''${glslPrefix} "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_VL.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode B (HQ)"'';
            "CTRL+3" =
              ''${glslPrefix} "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode C (HQ)"'';
            "CTRL+4" =
              ''${glslPrefix} "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_VL.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${anime4k}/Anime4K_Restore_CNN_M.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode A+A (HQ)"'';
            "CTRL+5" =
              ''${glslPrefix} ${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_VL.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Restore_CNN_Soft_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode B+B (HQ)"'';
            "CTRL+6" =
              ''${glslPrefix} "${anime4k}/Anime4K_Clamp_Highlights.glsl:${anime4k}/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl:${anime4k}/Anime4K_AutoDownscalePre_x2.glsl:${anime4k}/Anime4K_AutoDownscalePre_x4.glsl:${anime4k}/Anime4K_Restore_CNN_M.glsl:${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"; show-text "Anime4K: Mode C+A (HQ)"'';

            "CTRL+0" =
              ''no-osd change-list glsl-shaders clr ""; no-osd set hr-seek-framedrop yes; no-osd vf clr ""; show-text "cleared !"'';
          };
          config = rec {
            osc = false;
            border = false;

            vo = "gpu-next,gpu,dmabuf-wayland";
            hwdec = "vulkan,vaapi";
            video-sync = "display-resample";
            interpolation = true;
            icc-profile-auto = true;
            blend-subtitles = "video";

            fs = true;
            mute = true;
            keepaspect = true;

            alang = "chi,zh,ja,en";
            audio-file-auto = "exact";

            slang = "zh-CN,zh-Hans,cmn-Hans,chi,chs,sc,zh,en";

            sub-font = "Maple Mono CN";
            sub-auto = "fuzzy";

            osd-font = sub-font;
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
