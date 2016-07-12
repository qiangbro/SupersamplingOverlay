# SupersamplingOverlay
利用超取样(Supersampling)原理，向原影片覆盖内容，且使覆盖的内容圆滑而不影响原影片画质。

###原理###

SSOverlay函数会基于原影片，按照给定的宽高比(dar)、超取样比率(ss_rate)，拉伸出一个超取样影片。
使用者可以通过编写回调代码(callback)，向超取样影片添加需要覆盖的内容。
本函数通过对覆盖前后的图像进行比较，得到超取样的覆盖内容，进行模糊处理(blur)，拉伸回原影片分辨率，合并到原影片。
以此实现使覆盖的内容圆滑而不影响原影片画质。


###典型应用###

*  向SAR=4:3的影片上覆盖16:9的ASS字幕，而无需改变影片分辨率
*  让字幕边缘像potplayer加载字幕那样柔和圆滑


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


