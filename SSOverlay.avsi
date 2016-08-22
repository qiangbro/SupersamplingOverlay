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
#   SSOverlay 1.1.5
#
#   利用超取样原理进行内容覆盖。
#
#   Author : Mikey
#   E-mail : qiangbro@qq.com
#   所在团队 : 有村花纯字幕组
#   项目网址 : https://github.com/qiangbro/SupersamplingOverlay
#


# --- CODE SAMPLES ---
#
#   ......
#
#   LoadPlugin("E:\program_media\avisynth-plugin\VSFilter-v2.39\VSFilter.dll")
#   LoadPlugin("E:\program_media\avisynth-plugin\masktools2-x86\masktools2.dll")
#   Import("E:\program_media\Mikey's Fansub Utilities\avisynth-plugins\SSOverlay.avsi")
#
#   ......
#
#   SSOverlay("""
#       TextSub("helloworld.ass")
#   """, dar_fit=16.0/9, ss_rate=1.2, blur=0.7)
#


# --- 使用说明 ---
#
#   SSOverlay(clip src, string callback, float "dar_fit", float "ss_rate", float "blur")
#
#   原理:
#       按照给定的宽高比(dar_fit)、超取样比率(ss_rate)，拉伸出一个超取样影片，
#       通过在超取样影片上执行回调代码(callback)，添加需要覆盖的内容，
#       （如：用TextSub/TextSubMod添加字幕）
#       通过进行比较，得到覆盖前后的差异影片。
#       对差异影片进行模糊处理(blur) 并拉伸回原影片分辨率，与原影片进行合并。
#
#   特点：
#       ① 按需定制所覆盖的内容
#       ② 画面中未被覆盖内容的画面部分不会有任何改动。
#
#   参数:
#       src: 原影片
#       callback：向超取样影片添加所需覆盖的内容的回调代码，可自主定义所覆盖的内容
#       ss_rate：超取样拉伸放大的比率，参与计算超取样影片的分辨率。默认=1.0，建议取1.2
#       dar_fit：通过改变超取样影片的宽度来改变宽高比。不填则采用片源宽高比。hdtv片源应取dar_fit=16.0/9
#       blur：通过模糊让字幕边缘柔和（仿potplayer挂字幕的感觉）默认=0.0，取值范围0.0~1.58，建议取0.7
#
#   返回值：
#       已完成覆盖的影片。
#   


# --- REQUIREMENTS ---
#
#   Avisynth 2.58 或更高版本
#
#   MaskTools2 : http://avisynth.nl/index.php/MaskTools2
#


###---已知问题---
#
#   如果ss_rate值稍大，使得压制工作效率降低，建议用Avisynth+ MT开多线程
#   Avisynth+ MT pfmod 在开启多线程时，需要设置以下滤镜的MT模式
#
#~ SetFilterMTMode("Eval", 3)
#
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
#   平时接触到的某些TS片源，实际像素分辨率=1440x1080，显示分辨率=1920x1080
#   要用TextSub向这种片源上覆盖字幕的话，一般需要先将影片拉伸到1920x1080或1280x720，再调用TextSub进行覆盖，
#   以得到比例正确的字幕。
#
#   那么问题就来了。能否直接向1440x1080分辨率的影片覆盖字幕，且还能保证画面按16:9显示时，字幕是正确的比例呢？
#
#   一种简单的方案是将片源拉伸到1920x1080叠加字幕，之后再拉伸回1440x1080。
#   当然，字幕比例是正确的，但图像经过两次拉伸，画质就被破坏了。一般人不会这么做。
#
#   还有种办法，去Aegisub把字幕拉伸到4:3比例，然后再回到avs用TextSub覆盖。
#   这是个可行的办法。但是这样创建了成品字幕的一个分支版本。
#
#   接下来我来介绍使用SSOverlay的办法。
#   将TextSub语句写入SSOverlay的参数中，并指定dar_fit=16.0/9，即可得到所要的字幕
#   SSOverlay("""
#       TextSub("helloworld.ass")
#   """, dar_fit=16.0/9)
#
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
#       参考 https://en.wikipedia.org/wiki/Aspect_ratio_(image)
#
#
#   Supersampling:
#       参考 https://en.wikipedia.org/wiki/Supersampling
#


# --- CHANGELOG ---
#
#   2016.8.22
#   1.1.5 by Mikey
#       去掉dar参数，改为dar_fit
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



function SSOverlay(clip src, string callback, float "dar_fit", float "ss_rate", float "blur") {
    
    callback = Default(callback, """""")
    ss_rate = Default(ss_rate, 1.0)
    blur = Default(blur, 0.0)


    #创建超取样影片
    ss_h=round(src.height * ss_rate / 4) * 4 #m4(height*1.5)
    ss_w=round(Defined(dar_fit) ? (src.height * ss_rate * dar_fit / 4) : (src.width * ss_rate / 4)) * 4 #m4(width*1.5)
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
