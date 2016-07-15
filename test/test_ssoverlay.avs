

LoadPlugin("E:\program_media\avisynth-plugin\masktools\masktools2-b1-x86.dll")
Import("H:\fansub-work\[fansub-dev\SupersamplingOverlay\SSOverlay.avsi")

BlankClip(width=1280, height=720, color=$333333)
ConvertToYV12()

SSOverlay("""
Subtitle("supers:The quick brown fox jump sover the lazy dog", size=65,y=10)
""", dar="16/9", ss_rate=1.3, blur=0.5)

Subtitle("normal:The quick brown fox jump sover the lazy dog", size=50,y=100)

