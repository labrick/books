# 3.11.04.01 MTD基础

2017-02-21

------------

## MTD配置

    -> Device Drivers
        -> Memory Technology Device (MTD) support (MTD [=y])
            -> Direct char device access to MTD devices (MTD_CHAR [=y])
            -> Caching block device access to MTD devices(MTD_BLOCK [=y])
            -> Self-contained MTD device drivers
                -> Test driver using RAM (CONFIG_MTD_MTDRAM [=y])
                    -> (4096) MTDRAM device size in KiB (CONFIG_MTDRAM_TOTAL_SIZE [=4096])
                    -> (128) MTDRAM erase block size in KiB (CONFIG_MTDRAM_ERASE_SIZE [=128])

CONFIG_MTD_CHAR：开启字符设备模式的访问功能，实际上是一种串行访问方式，每一次串行读取或写入一字节。

CONFIG_MTD_BLOCK：开启以块模式访问MTD设备的功能，这是磁盘驱动器所使用的访问方式，一次读取或写入多个块，每个块包含若干字节的数据。

CONFIG_MTD_MTDRAM：启用一个特殊的测试驱动程序，它允许我们在开发主机上查看MTD子系统，即使没有实际的MTD设备也没有关系。其中RAM模拟的RAM的总容量为4M，块大小为128K。

## 挂载JFFS2镜像到MTD设备

    # mkfs.jffs2 -d ./jffs2-image-dir -o jffs2.bin
    # modprobe jffs2
    # modprobe mtdblock
    # modprobe mtdram
    $ ls /dev/mtdblock0
    mtdblock0
    # dd if=jffs2.bin of=/dev/mtdblock0
    2+1 records in
    2+1 records out
    1244 bytes (1.2 kB, 1.2 KiB) copied, 0.000163355 s, 7.6 MB/s
    # mount -t jffs2 /dev/mtdblock0 ./tmp/ 

其中jffs2.ko/mtdblock.ko/mtdram.ko在`/lib/modules/linux_version-generic/kernel/`目录下，find即可找到。

## 注意

操作JFFS2文件系统时唯一的限制是不能改变镜像的大小，而它的大小会受到两个因素的限制：

1. 内核配置工具中配置这个MTDRAM测试驱动时所限制的大小（此处为4M）。
2. 创建JFFS2镜像时使用mkfs.jffs2工具固定的镜像的大小。

更关键的一点：这里不同于回环设备，**我们复制的文件和挂载的JFFS2文件系统之间没有关系，因此如果修改文件系统的内容，然后卸载它，我们所做的修改就会丢失。**如果想保存这些修改，则必需将他们复制回一个文件中。

    # dd if=/dev/mtdblock0 of=./your-modified-fs-image.bin

这个命令可以将修改的内容另外保存起来，实际上就是复制/dev/mtdblock0设备中的内容为一个新的文件镜像。这里还需要注意到**这个新文件镜像的大小等于设备的大小**，这也是了解设备该设备大小的一种方法。

