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
#   SSOverlay 1.1.1
#
#   利用超取样(Supersampling)原理向原影片添加覆盖，使所覆盖的内容圆滑而不影响原影片画质。
#
#   本函数会按照给定的宽高比(dar)、超取样比率(ss_rate)，基于原影片拉伸出一个超取样影片，
#   使用者可以通过编写回调代码(callback)，向超取样影片添加需要覆盖的内容，得到正确比例的覆盖，
#   最后本函数会将覆盖的内容进行模糊处理(blur)，伸缩回原比例，合并到原影片。
#
#   典型应用：
#       ① 向SAR=4:3的影片上覆盖16:9的ASS字幕，而无需改变影片分辨率
#       ② 让字幕边缘像potplayer加载字幕那样柔和圆滑
#
#
#   Author : Mikey
#   E-mail : qiangbro@qq.com
#
#   所在团队 : 有村花纯字幕组
#
#   感谢您的使用与测试。如果遇到bug，欢迎反馈。
#   如果您要复制、发布和修改本程序代码，请遵守 WTFPL 2.0，希望本程序对您有帮助。
#   再次感谢，祝您生活愉快！
#
#       Mikey
#       2016.6
#



# --- VERSION HISTORY ---
#
#   2016.06.27
#   1.1.1 by Mikey
#       编写文案。
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



# --- REQUIREMENTS ---
#
#   MaskTools2 : http://avisynth.nl/index.php/MaskTools2
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
#   更多内容请阅读 https://en.wikipedia.org/wiki/Aspect_ratio_(image)
#
#
#   Supersampling:
#       超取样，一种抗锯齿的原理。
#       通过插值得到更精细的样本进行取样以实现抗锯齿（可能我表达的并不对），参考 https://en.wikipedia.org/wiki/Supersampling
#



# --- 故事引子 ---
#
#   平时接触到的某些TS片源，分辨率=1440x1080，显示宽高比=16:9，
#   要向这种片源上用TextSub覆盖字幕的话，需要先将影片拉伸到1920x1080或1280x720，再调用TextSub进行覆盖，
#   否则，最后成品以16:9播放时，字幕会显得不正确，变胖了。
#
#
#   那么问题就来了。能否不对1440x1080分辨率的影片进行拉伸，照样能正确地覆盖字幕呢？
#
#   一种简单的方案是将片源拉伸到1920x1080叠加字幕，之后再拉伸回1440x1080。
#   当然，这样能在1440x1080分辨率的影片上正确地覆盖字幕。然而片源经过两次拉伸，画质就被破坏了。
#
#   有别的办法么？
#



# --- SSOverlay使用说明 ---
#
#   SSOverlay函数可以不对影片做任何拉伸，将字幕按正确的比例覆盖到影片上去。
#
#   这是如何实现的呢？
#
#   本函数会按照给定的宽高比(dar)、超取样比率(ss_rate)，基于原影片拉伸出一个超取样影片，
#   使用者可以通过编写回调代码(callback)，向超取样影片添加需要覆盖的内容，得到正确比例的覆盖，
#   最后本函数会将覆盖的内容进行模糊处理(blur)，伸缩回原比例，合并到原影片。
#
#
#   函数输入输出说明：
#   SSOverlay(clip src, string callback, string "dar", float "ss_rate", float "blur")
#   参数:
#       src: 要进行覆盖的影片
#       callback：向超取样影片添加所需覆盖的内容的回调代码。
#       dar：覆盖内容的正确显示宽高比，用于计算超取样影片的分辨率。默认="16/9"
#       ss_rate：超取样比率，用于计算超取样影片的分辨率。默认=1.0
#       blur：最终进行模糊处理时的强度。默认=0.0，取值范围0.0~1.58
#   返回值：
#       返回覆盖了所需覆盖的内容的影片。
#   



# --- CODE SAMPLES ---
#
#   以下示例展示向1440x1080分辨率的影片上添加16:9的字幕，
#   并且让字幕边缘柔和圆滑。
#
#
#   [伸懒腰旅行.俏丽女孩的豪华之旅.悉尼篇.逢泽莉娜.中字.1080p-RinaBAR.avs]
#
#   LoadPlugin("E:\program_media\DG2044\dgindexnv\DGDecodeNV.dll")
#   LoadPlugin("E:\program_media\avisynth-plugin\ffms2-2.22-msvc\x86\ffms2.dll")
#   LoadPlugin("E:\program_media\avisynth-plugin\VSFilter-v2.39\VSFilter.dll")
#   LoadPlugin("E:\program_media\avisynth-plugin\masktools2-x86\masktools2.dll")
#   Import("E:\program_media\[A.K.] Mikey's Fansub Utilities Pack\avisynth-plugins\SSOverlay-1.1.avsi")
#
#   v = DGSource("H:\fansub-work\[任务\2016.05.29 セノビタビ\02-悉尼\src\2016060100350105-フジテレビ-セノビタビ。.dgi")
#   a = FFAudioSource("H:\fansub-work\[任务\2016.05.29 セノビタビ\02-悉尼\src\2016060100350105-フジテレビ-セノビタビ。--track02--fix-delay.aac").DelayAudio(0.001)
#   AudioDub(v, a)
#
#   Trim(936,3632)++Trim(7230,43492)++Trim(47090,47987)++Trim(52035,52633)
#
#   SSOverlay("""
#       TextSub("伸懒腰旅行.悉尼.班花--已翻译--已轴.ass")
#   """, ss_rate=1.1, blur=0.5)




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
    ss_sub = SSOverlay_eval_callback(ss_src, callback)

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

function SSOverlay_eval_callback(clip ss, string callback) {
    ss
    Eval(callback, "ssoverlay_callback")
}
