# 3.12.01 文件系统工具

2017-02-16

-------------

1. 分区

        # fdisk /dev/sdX
    
    fdisk工具可以查看/修改块设备的分区信息。

2. 格式化分区

        # mkfs.fs_type /dev/sdXX -L CFlash_Boot_Vol

    将固定分区格式化为fs_type类型，CFlash_Boot_Vol为卷标。

3. 挂载分区

        # mount /dev/sdXX /mnt/hdd
        # mount 挂载设备  挂点

4. 文件系统完整性检查

        # e2fsck /dev/sda
        e2fsck 1.42.13 (17-May-2015)
        /dev/sda: clean, 11/7331840 files, 508179/29305206 blocks

        # e2fsck /dev/sdb
        e2fsck 1.42.13 (17-May-2015)
        /dev/sdb is in use.
        e2fsck: Cannot continue, aborting.

    e2fsck命令用于检查一个ex2文件系统的完整性。有几个原因会造成文件系统的损坏，最常见的原因就是**系统意外断电**。Linux发行版在关机时会关闭所有已打开的文件并**卸载文件系统（假设系统是正常有序地关闭的）。**，不过在ex3中很容易恢复（ext3比ext2多了日志系统，简单回放下就知道如何修正）

    e2fsck应该运行于一个未挂载的文件系统上。虽然有可能将它运行在一个已挂载的文件系统上，但这样做会对磁盘或闪存设备的内部文件系统结构造成严重损害。

        # e2fsck -y /dev/sdXX

    其对文件系统进行扫描，并试图修复某些错误，但不要报太大的希望。

5. ext2 ==> ext3

        # tune2fs -j /dev/sdXX

    tune2fs会创建一个名为.journal的日志文件，实质上就是把ext2文件系统无缝转化为了ext3文件系统。
    
    ext3支持最大容量16TB，ext4支持最大容量1EB(EB: exbibyte，2^60B)

6. 构建JFFS2镜像

        # apt-get install mtd-tools
        # mkfs.jffs2 -d ./jffs2-image-dir -o jffs2.bin

    jffs2-image-dir指文件系统的目录，jffs2.bin是生成的JFFS2镜像。

    注意：**JFFS2镜像是专用于闪存的文件系统镜像，所以并不能直接挂载到回环设备上。**

7. 构建cramfs镜像

        # apt-get install cramfsprogs
        # mkcramfs . ../cramfs.image
        # mkdir ../tmp
        # mount -o loop ../cramfs.image ../tmp
