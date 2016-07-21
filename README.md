# SupersamplingOverlay
利用超取样(Supersampling)原理，向原影片添加覆盖。

由于使用了超采样，可以对覆盖的内容施加模糊效果、更高的采样点可以减少锯齿，以达到更好的覆盖效果。

###原理###

基于原影片，按照给定的宽高比(dar)、超取样比率(ss_rate)，拉伸出一个超取样影片。
通过在超取样影片上执行回调代码(callback)，添加需要覆盖的内容。
通过进行比较，得到覆盖前后的差异影片，对差异影片进行模糊处理(blur) 并拉伸回原影片分辨率，与原影片进行合并。
以此实现使覆盖的内容圆滑而不影响原影片画质。


###典型应用###

* 向1440x1080的影片上按16:9的比例覆盖ASS字幕
* 让字幕边缘像potplayer加载字幕那样柔和圆滑

###CODE EXAMPLES###

    LoadPlugin("E:\program_media\DG2044\dgindexnv\DGDecodeNV.dll")
    LoadPlugin("E:\program_media\avisynth-plugin\ffms2-2.22-msvc\x86\ffms2.dll")
    LoadPlugin("E:\program_media\avisynth-plugin\VSFilter-v2.39\VSFilter.dll")
    LoadPlugin("E:\program_media\avisynth-plugin\masktools2-x86\masktools2.dll")
    Import("E:\program_media\[A.K.] Mikey's Fansub Utilities Pack\avisynth-plugins\SSOverlay-1.1.avsi")
    
    v = DGSource("H:\fansub-work\[任务\2016.05.29 セノビタビ\02-悉尼\src\2016060100350105-フジテレビ-セノビタビ。.dgi")
    a = FFAudioSource("H:\fansub-work\[任务\2016.05.29 セノビタビ\02-悉尼\src\2016060100350105-フジテレビ-セノビタビ。--track02--fix-delay.aac").DelayAudio(0.001)
    AudioDub(v, a)
    
    Trim(936,3632)++Trim(7230,43492)++Trim(47090,47987)++Trim(52035,52633)
    
    SSOverlay("""
    
    TextSub("伸懒腰旅行.悉尼.班花--已翻译--已轴.ass")
    
    """, dar="16/9", ss_rate=1.1, blur=0.4)
    

Author : Mikey

E-mail : qiangbro@qq.com

项目网址 : https://github.com/qiangbro/SupersamplingOverlay

下载 : https://github.com/qiangbro/SupersamplingOverlay/releases

所在团队 : 有村花纯字幕组  

感谢您的使用与测试，如果遇到bug，欢迎反馈。

如果您要复制、发布和修改本程序代码，请遵守 WTFPL 2.0。

再次感谢，祝您生活愉快！

Mikey
2016.7


