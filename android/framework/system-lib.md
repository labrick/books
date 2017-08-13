# system/lib目录

2017-01-09

-------------------------

system/lib下都是系统关键的本地库


| 库名称                             | 简介        |
| :--------------------------------  | :-----------|
| system/lib/libaes.so 
| system/lib/libagl.so
| system/lib/libandroid_runtime.so   | Android运行时库
| system/lib/libandroid_servers.so   | 系统服务组件
| system/lib/libaudio.so             | 音频处理
| system/lib/libaudioeq.so           | EQ均衡器
| system/lib/libaudioflinger.so      | 音频过滤器
| system/lib/libbluetooth.so         | 蓝牙组件
| system/lib/libc.so
| system/lib/libcamera.so            | 超相机组件
| system/lib/libcameraservice.so
| system/lib/libcorecg.so
| system/lib/libcrypto.so            | 加密组件
| system/lib/libctest.so
| system/lib/libcutils.so
| system/lib/libdbus.so
| system/lib/libdl.so
| system/lib/libdrm1.so              | DRM解析库
| system/lib/libdrm1_jni.so
| system/lib/libdvm.so
| system/lib/libexif.so
| system/lib/libexpat.so
| system/lib/libFFTEm.so
| system/lib/libGLES_CM.so
| system/lib/libgps.so
| system/lib/libhardware.so
| system/lib/libhgl.so
| system/lib/libhtc_ril.so
| system/lib/libicudata.so
| system/lib/libicui18n.so
| system/lib/libicuuc.so
| system/lib/liblog.so
| system/lib/libm.so
| system/lib/libmedia.so
| system/lib/libmediaplayerservice.so
| system/lib/libmedia_jni.so
| system/lib/libnativehelper.so
| system/lib/libnetutils.so
| system/lib/libOmxCore.so
| system/lib/libOmxH264Dec.so
| system/lib/libpixelflinger.so
| system/lib/libpvasf.so
| system/lib/libpvasfreg.so
| system/lib/libpvauthor.so
| system/lib/libpvcommon.so
| system/lib/libpvdownload.so
| system/lib/libpvdownloadreg.so
| system/lib/libpvmp4.so
| system/lib/libpvmp4reg.so
| system/lib/libpvnet_support.so
| system/lib/libpvplayer.so
| system/lib/libpvrtsp.so
| system/lib/libpvrtspreg.so
| system/lib/libqcamera.so
| system/lib/libreference-ril.so
| system/lib/libril.so
| system/lib/librpc.so
| system/lib/libsgl.so
| system/lib/libsonivox.so
| system/lib/libsoundpool.so
| system/lib/libsqlite.so
| system/lib/libssl.so
| system/lib/libstdc++.so
| system/lib/libsurfaceflinger.so
| system/lib/libsystem_server.so
| system/lib/libthread_db.so
| system/lib/libUAPI_jni.so
| system/lib/libui.so
| system/lib/libutils.so
| system/lib/libvorbisidec.so
| system/lib/libwbxml.so
| system/lib/libwbxml_jni.so
| system/lib/libwebcore.so
| system/lib/libwpa_client.so
| system/lib/libxml2wbxml.so
| system/lib/libz.so
| system/lib/modules
| system/lib/modules/wlan.ko

我们知道android的java层次也是通过`System.loadLibrary();`来加载so库文件，那么如果我们替换了这里的so库是不是也可以达到更新系统的目的呢？
