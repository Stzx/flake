{
  pkgs,
  ...
}:

let
  inherit (pkgs) anime4k;
in
{
  programs.mpv = {
    bindings = {
      "CTRL+v" = ''cycle-values vo "gpu-next" "dmabuf-wayland"'';

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

      "CTRL+0" = ''no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"'';
    };
    config = {
      osc = false;
      border = false;

      vo = "gpu-next";
      hwdec = "auto";
      video-sync = "display-resample";
      interpolation = true;
      icc-profile-auto = true;

      fs = true;
      mute = true;
      keepaspect = true;

      alang = "chi,zh,ja,en";
      slang = "chi,zh,en";
      sub-auto = "fuzzy";
      blend-subtitles = "video";
    };
    profiles = {
      "unscaled" = {
        profile-cond = "p['video-params/h'] <= 1080";
        video-unscaled = true;
      };
    };
    defaultProfiles = [ "high-quality" ];
    scripts = with pkgs.mpvScripts; [
      modernx
      mpris
    ];
  };
}
