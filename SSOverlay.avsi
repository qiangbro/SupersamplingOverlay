#             DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                     Version 2, December 2004
# 
#  Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>
# 
#  Everyone is permitted to copy and distribute verbatim or modified
#  copies of this license document, and changing it is allowed as long
#  as the name is changed.
# 
#             DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#    TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
# 
#   0. You just DO WHAT THE FUCK YOU WANT TO.


#
#   SSOverlay 1.1.4
#
#   利用超取样原理进行高质量的内容覆盖。
#
#   Author : Mikey
#   E-mail : qiangbro@qq.com
#   所在团队 : 有村花纯字幕组
#   项目网址 : https://github.com/qiangbro/SupersamplingOverlay
#


# --- CODE SAMPLES ---
#
#   LoadPlugin("E:\program_media\DG2044\dgindexnv\DGDecodeNV.dll")
#   LoadPlugin("E:\program_media\avisynth-plugin\VSFilter-v2.39\VSFilter.dll")
#   LoadPlugin("E:\program_media\avisynth-plugin\masktools2-x86\masktools2.dll")
#   Import("E:\program_media\Mikey's Fansub Utilities\avisynth-plugins\SSOverlay.avsi")
#
#   DGSource("H:\fansub-work\[任务\2016.05.29 セノビタビ\02-悉尼\src\2016060100350105-フジテレビ-セノビタビ。.dgi")
#   Trim(936,3632)++Trim(7230,43492)++Trim(47090,47987)++Trim(52035,52633)
#
#   SSOverlay("""
#       TextSub("伸懒腰旅行.悉尼.班花--已翻译--已轴.ass")
#   """, ss_rate=1.2, blur=0.6)
#


# --- 使用说明 ---
#
#   SSOverlay(clip src, string callback, string "dar", float "ss_rate", float "blur")
#
#   原理:
#       本函数基于原影片，按照给定的宽高比(dar)、超取样比率(ss_rate)，拉伸出一个超取样影片。
#       通过在超取样影片上执行回调代码(callback)，添加需要覆盖的内容。
#       （如：用TextSub/TextSubMod添加ASS字幕，用Overlay函数添加png水印等）
#       通过进行比较，得到覆盖前后的差异影片。
#       对差异影片进行模糊处理(blur) 并拉伸回原影片分辨率，与原影片进行合并。
#       以此实现使覆盖的内容圆滑而不影响原影片画质。
#
#   参数:
#       src: 原影片
#       callback：向超取样影片添加所需覆盖的内容的回调代码。
#       dar：覆盖内容的显示宽高比，参与计算超取样影片的分辨率。默认="16/9"
#       ss_rate：超取样比率，参与计算超取样影片的分辨率。默认=1.0
#       blur：最终进行模糊处理时的强度。默认=0.0，取值范围0.0~1.58
#
#   返回值：
#       已完成覆盖的影片。
#   


# --- REQUIREMENTS ---
#
#   Avisynth 2.58 或更高
#
#   MaskTools2 : http://avisynth.nl/index.php/MaskTools2
#


###---已知问题---
#
#   Avisynth+ MT pfmod 开启多线程模式下，可能需要手动设置所用的滤镜的mt模式，否则会报错
#~  SetFilterMTMode("Eval", 3)
#
#   masktools2的mt模式
#~ SetFilterMTMode("mt_invert",           MT_MULTI_INSTANCE)
#~ SetFilterMTMode("mt_binarize",         MT_MULTI_INSTANCE)
#~ SetFilterMTMode("mt_inflate",          MT_MULTI_INSTANCE)
#~ SetFilterMTMode("mt_deflate",          MT_MULTI_INSTANCE)
#~ SetFilterMTMode("mt_inpand",           MT_MULTI_INSTANCE)
#~ SetFilterMTMode("mt_expand",           MT_MULTI_INSTANCE)
#~ SetFilterMTMode("mt_lut",              MT_MULTI_INSTANCE)
#~ SetFilterMTMode("mt_lutxy",            MT_MULTI_INSTANCE)
#~ SetFilterMTMode("mt_lutxyz",           MT_MULTI_INSTANCE)
#~ SetFilterMTMode("mt_luts",             MT_MULTI_INSTANCE)
#~ SetFilterMTMode("mt_lutf",             MT_MULTI_INSTANCE)
#~ SetFilterMTMode("mt_lutsx",            MT_MULTI_INSTANCE)
#~ SetFilterMTMode("mt_lutspa",           MT_MULTI_INSTANCE)
#~ SetFilterMTMode("mt_merge",            MT_MULTI_INSTANCE)
#~ SetFilterMTMode("mt_logic",            MT_MULTI_INSTANCE)
#~ SetFilterMTMode("mt_convolution",      MT_MULTI_INSTANCE)
#~ SetFilterMTMode("mt_mappedblur",       MT_MULTI_INSTANCE)
#~ SetFilterMTMode("mt_makediff",         MT_MULTI_INSTANCE)
#~ SetFilterMTMode("mt_average",          MT_MULTI_INSTANCE)
#~ SetFilterMTMode("mt_adddiff",          MT_MULTI_INSTANCE)
#~ SetFilterMTMode("mt_clamp",            MT_MULTI_INSTANCE)
#~ SetFilterMTMode("mt_motion",           MT_MULTI_INSTANCE)
#~ SetFilterMTMode("mt_edge",             MT_MULTI_INSTANCE)
#~ SetFilterMTMode("mt_hysteresis",       MT_MULTI_INSTANCE)
#


# --- STORY ---
#
#   平时接触到的某些TS片源，实际分辨率=1440x1080，显示分辨率=1920x1080
#   要向这种片源上用TextSub覆盖字幕的话，需要先将影片拉伸到1920x1080或1280x720，再调用TextSub进行覆盖，
#   否则，覆盖的字幕比例会不正确，变胖了。
#
#   那么问题就来了。能否以正确的比例向1440x1080分辨率的影片覆盖字幕呢？
#
#   一种简单的方案是将片源拉伸到1920x1080叠加字幕，之后再拉伸回1440x1080。
#   当然，字幕比例是正确的，但经过两次拉伸，字幕以外的区域图像就被破坏了。
#
#   有别的办法么？
#
#   SSOverlay函数可以不影响不相关的区域，将字幕按正确的比例覆盖到影片上去。
#
#
#   SSOverlay典型应用：
#       向1440x1080的影片上覆盖按16:9比例设计的ASS字幕
#       向1440x1080的影片上覆盖按16:9比例设计的PNG水印
#       让字幕边缘柔和圆滑（像potplayer加载字幕那样）
#
#   特点：
#       ① 可自主定义所覆盖的内容（通过callback参数编写回调代码）
#       ② 可自主定义所覆盖内容的宽高比例（通过dar参数）
#       ③ 可自主定义超取样影片的大小（通过ss_rate参数）
#       ④ 可自主定义所覆盖内容的模糊强度，使所覆盖内容圆滑避免锯齿（通过blur参数）
#       ⑤ 画面中未被覆盖内容的画面部分不会有任何改动，无画质损失。
#
#
#   使用建议
#       如果ss_rate值稍大，使得播放很吃力，或者压制时CPU使用率不高，
#       建议使用多线程，如Avisynth MT、Avisynth+ MT-pfmod
#


# --- 名词解释 ---
#
#   DAR:
#       Display Aspect Ratio, 显示宽高比。
#       常见的如：DAR=16:9
#
#   SAR:
#       Storage Aspect Ratio, 数值上等于分辨率宽高比。
#       常见的如：1920x1080分辨率片源的SAR=16:9，1440x1080分辨率片源的SAR=4:3
#
#   PAR:
#       Pixel Aspect Ratio, 像素宽高比。
#
#   DAR、SAR、PAR 始终满足关系:
#       SAR × PAR = DAR
#       PAR = DAR/SAR
#
#       以上参考 https://en.wikipedia.org/wiki/Aspect_ratio_(image)
#
#
#   Supersampling:
#       超取样，一种抗锯齿的原理。
#       通过插值得到更精细的样本进行取样以实现抗锯齿（可能我表达的并不对）
#       参考 https://en.wikipedia.org/wiki/Supersampling
#


# --- CHANGELOG ---
#
#   2016.6.27, 7.1, 7.12, 7.15
#   1.1.1 ~ 1.1.4 by Mikey
#       编写整理文案。当然文案也是脚本的一部分。
#       私用的函数用双下划线开头。
#
#
#   2016.06.26
#   1.1 by Mikey
#       添加模糊功能，支持blur参数。
#       
#
#   2016.6.19
#   1.0 by Mikey
#       实现基本功能，支持callback、dar、ss_rate 参数。
#



function SSOverlay(clip src, string callback, string "dar", float "ss_rate", float "blur") {
    
    callback = Default(callback, """""")

    dar = Default(dar, "16/9")
    dar_float = Eval("1.00 * " + dar)

    ss_rate = Default(ss_rate, 1.0)

    blur = Default(blur, 0.0)


    #创建超取样影片
    ss_h=round(src.height * ss_rate / 4) * 4 #m4(height*1.5)
    ss_w=round(src.height * ss_rate / 4 * dar_float) * 4 #m4(width*1.5)
    ss_src = BlackmanResize(src, ss_w, ss_h)
    
    #在超取样影片上执行回调代码
    ss_sub = __SSOverlay_eval(ss_src, callback)

    #进行比较得到变化
    ss_dif = mt_lutxy(ss_src, ss_sub, "x y == 0 255 ?", U=3, V=3 )

    #执行模糊
    blur_dif = ss_dif.Blur(blur, MMX=True)
    blur_sub = ss_sub.Blur(blur, MMX=True)
    
    #将覆盖的内容拉伸回原分辨率，覆盖到原影片上
    dif = blur_dif.Spline36Resize(src.width, src.height)
    sub = blur_sub.Spline36Resize(src.width, src.height)
    mt_merge(src, sub, dif, U=3, V=3)

}

function __SSOverlay_eval(clip ss, string callback) {
    ss
    Eval(callback, "ssoverlay_callback")
}
