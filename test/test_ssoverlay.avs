
#avs2.6
LoadPlugin("E:\program_media\avisynth-plugin\masktools\masktools2-b1-x86.dll")

#avs2.58
#~ LoadPlugin("E:\program_media\xiaowan_rev190\tools\avsfilter\mt_masktools-25.dll")

Import("H:\fansub-work\[fansub-dev\SupersamplingOverlay\SSOverlay.avsi")

BlankClip(width=1920, height=1080, color=$333333)

ConvertToYV12()

SSOverlay("""
Subtitle("������ģ��: THE QUICK BROWN FOX!!! ����������", size=130,y=10,font="΢���ź�")
""", dar_fit=16.0/9, ss_rate=1.3, blur=0.7)

Subtitle("ԭʼ��Ч��: THE QUICK BROWN FOX!!! ����������", size=100,y=100,font="΢���ź�")

