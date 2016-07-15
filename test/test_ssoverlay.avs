
#avs2.6
#~ LoadPlugin("E:\program_media\avisynth-plugin\masktools\masktools2-b1-x86.dll")

#avs2.58
LoadPlugin("E:\program_media\xiaowan_rev190\tools\avsfilter\mt_masktools-25.dll")

Import("H:\fansub-work\[fansub-dev\SupersamplingOverlay\SSOverlay.avsi")

BlankClip(width=1920, height=1080, color=$333333)

ConvertToYV12()

SSOverlay("""
Subtitle("超采样模糊: THE QUICK BROWN FOX!!! 超采样测试", size=130,y=10,font="微软雅黑")
""", dar="16/9", ss_rate=1.3, blur=0.5)

Subtitle("原始字效果: THE QUICK BROWN FOX!!! 超采样测试", size=100,y=100,font="微软雅黑")

