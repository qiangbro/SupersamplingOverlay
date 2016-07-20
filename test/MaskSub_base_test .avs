

#   this script works good.
#   MaskSub returns a RGB32 clip, I can use MaskSub+Overlay to merge ass subtitles to video source.



LoadPlugin("E:\program_media\DGDecNV2049\DGDecodeNV.dll")

LoadPlugin("VSFilter-2.41.322_x86.dll")

src = DGSource("H:\fansub-work\[任务\[存档\2015\2015.07.06 スカッとジャパン『となりの寿司ドロボー』\src-qtgmc\2015.07.06.隔壁的寿司小偷-qtgmc.dgi").Spline36Resize(1280,720)

subpath = "H:\fansub-work\[任务\[存档\2015\2015.07.06 スカッとジャパン『となりの寿司ドロボー』\2015.07.06 となりの寿司ドロボー.jpn.fix.ass"

sub = MaskSub(subpath, src.width, src.height, src.FrameRate(), src.FrameCount()).FlipVertical()#.blur(0.3)

alpha = sub.ShowAlpha()

Overlay(src, sub, mask=alpha)

