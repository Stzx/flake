{
  pkgs,
  ...
}:

{
  programs.mpv = {
    defaultProfiles = [ "high-quality" ];
    config = {
      hwdec = "auto";
      vo = "dmabuf-wayland";

      fs = true;
      mute = true;
      keepaspect = true;

      alang = "chi,zh,ja,en";
      slang = "chi,zh,en";

      osc = false;
    };
    scripts = [ pkgs.mpvScripts.modernz ];
  };
}
