# 附录A 名词缩写

2017-02-14

--------------

1. DKMS(Dynamic Kernel Module Support)

    DELL的一个项目，其为整个社区加快了驱动程序的开发、测试和检验，也便于用户安装所需的驱动程序。
    
      目的是：让依赖内核的模块源码独立出来以便升级内核时候可以容易地重新建立。这也使得Linux驱程编写人员能够尽快的提供他们的驱动而不用等待新版本的Linux内核发布，同时也打消了用户对模块能否在新内核上面重新编译的疑虑。

2. Completion Variables

    Completion Variables类似于信号量，可以认为是信号量的简化版本。在内核中Completion Variables用于vfork系统调用：当子进程终止时通过 Completion Variables通知父进程。

3. JFFS2(Second Journal File System)

    第二代日志闪存文件系统。

4. loopback device

    linux中的回环设备可以将一个普通文件当作块设备来使用。

    例如：我们可以先在一个普通文件中创建一个文件系统镜像，然后使用Linux的回环设备来挂载这个文件，就像是挂载一个块设备。

5. MTD(Memory Technology Device)

    存储技术设备子系统的目的是让内核支持种类繁多的类似内存的设备，比如闪存芯片。

6. Redboot

    Redboot是很多嵌入式板卡所使用的引导加载程序。

7. CFI(Common Flash Interface)

    公共闪存接口是一个工业标准方法，用于检测闪存芯片的特征（生产厂商/设备类型/总大小/擦除块大小）。
    
    内核配置开启CFI：

    -> Device Drivers
        -> Memory Technology Device (MTD) support (MTD [=y])
            -> RAM/ROM/Flash chip drivers
                -> Detect flash chips by Common Flash Interface (CFI) probe (MTD_CFI [=y])
