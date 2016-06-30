# SupersamplingOverlay
SSOverlay 1.1.1

利用超取样(Supersampling)原理向原影片添加覆盖，使所覆盖的内容圆滑而不影响原影片画质。

本函数会按照给定的宽高比(dar)、超取样比率(ss_rate)，
基于原影片拉伸出一个超取样影片，使用者可以通过编写回调代码(callback)，
向超取样影片添加需要覆盖的内容，得到正确比例的覆盖，
最后本函数会将覆盖的内容进行模糊处理(blur)，伸缩回原比例，合并到原影片。

典型应用：
  ① 向SAR=4:3的影片上覆盖16:9的ASS字幕，而无需改变影片分辨率
  ② 让字幕边缘像potplayer加载字幕那样柔和圆滑


Author : Mikey

E-mail : qiangbro@qq.com

项目网址 : https://github.com/qiangbro/SupersamplingOverlay

历史版本 : https://github.com/qiangbro/SupersamplingOverlay/releases

所在团队 : 有村花纯字幕组


感谢您的使用与测试。如果遇到bug，欢迎反馈。
如果您要复制、发布和修改本程序代码，请遵守 WTFPL 2.0，希望本程序对您有帮助。
再次感谢，祝您生活愉快！

Mikey
2016.6


