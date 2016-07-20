
#   whem i put MaskSub into a function, it doesn't work well:
#   MaskSub returns a RGB32 clip, but I can't get the Alpha Channel. Instead, i got a blackclip when calling ShowAlpha().

LoadPlugin("E:\program_media\DGDecNV2049\DGDecodeNV.dll")

LoadPlugin("VSFilter-2.41.322_x86.dll")

global MeGUI_darx = 16 global MeGUI_dary = 9

function SSTextSub(clip src, string subpath) {

    sub = MaskSub(subpath, src.width, src.height, src.FrameRate(), src.FrameCount()).FlipVertical()#.blur(0.3)

    alpha = sub.ShowAlpha()
    #FIXME: why ShowAlpha() returns blackclip??? I want the alpha channel of sub.

    Overlay(src, sub, mask=alpha)

}

src = DGSource("H:\fansub-work\[任务\[存档\2015\2015.07.06 スカッとジャパン『となりの寿司ドロボー』\src-qtgmc\2015.07.06.隔壁的寿司小偷-qtgmc.dgi").Spline36Resize(1280,720)

SSTextSub(src, "H:\fansub-work\[任务\[存档\2015\2015.07.06 スカッとジャパン『となりの寿司ドロボー』\2015.07.06 となりの寿司ドロボー.jpn.fix.ass")

