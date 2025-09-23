from vapoursynth import core, RGBS

clip = video_in

# clip_w = clip.width
# clip_h = clip.height
clip_fmt = clip.format

clip = core.resize.Point(clip, format=RGBS, matrix_in_s="709")
clip = core.rife.RIFE(clip, model=70, factor_num=5, factor_den=2, gpu_thread=2)
clip = core.resize.Point(clip, format=clip_fmt, matrix_s="709")

clip.set_output()
