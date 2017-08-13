# 3.9 初始RAM磁盘

2017-02-12

------------

初始RAM磁盘是一个功能完备的小型根文件系统，它通常包含一些指令，用于在系统引导完成之前加载一些特定的设备驱动文件。比如，在Red Hat和Ubuntu等Linux工作站发行版中，初始化RAM磁盘的作用就是**在挂载真正的根文件系统之前加载EXT3文件系统的设备驱动程序**。Initrd一般用于加载访问真正的根文件系统必需的设备驱动程序。

## 初始RAM磁盘配置

配置位置在：

    -> General setup
        -> Initial RAM filesystem and RAM disk (initramfs/initrd) support (BLK_DEV_INITRD [=y])

## initrd

initrd是一种比较老的镜像挂载方法。

大多数架构的引导加载程序先将压缩过的内核镜像加载到内存中，接着将initrd镜像加载到另外一段可用内存中。在这个过程中，引导加载程序负责在将控制权转交给内核之前，将initrd镜像的加载地址传递给内核（通过内核命令行）。

有些架构和平台会构造单个合成的二进制镜像。当引导加载程序所引导的Linux不支持加载initrd镜像时就会采用这种方式。在这种情况下，内核和initrd镜像只是简单地拼接在一起，形成一个合成地镜像。可以在内核地makefile(.../arch/arm/Makefile)中找到对这种合成镜像的引用，名称为bootpImage。目前，只有ARM架构使用了这种方式。

### initrd奥秘：linuxrc

当内核引导时，它首先会检测initrd镜像是否存在。然后，它会将这个压缩的二进制文件从指定的物理内存复制到一个合适的内核ramdisk中（之前的物理内存会归还给系统的可用内存池），并挂载它作为根文件系统（形式是一个内核ramdisk设备）。

initrd的奥秘来自一个存储在initrd镜像中的特殊文件的内容，当内核挂载初始的ramdisk时，它会查找一个名为linuxrc的特殊文件，并将其当作一个脚本文件来执行其中的命令，这种机制允许系统设计者控制initrd的行为。

### initrd探究

作为Linux引导过程的一部分，内核必需找到并挂载一个根文件系统。在引导过程的后期，内核通过函数prepare_namespace()决定要挂载的文件系统及挂载点，这个函数位于文件.../init/do_mounts.c中。如果内核支持initrd并且内核命令行也是按此进行配置的，内核会解压物理内中的initrd镜像，并最终将这个文件的内容复制到一个ramdisk设备(/dev/ram)中。这时，我们拥有了一个位于内核ramdisk中的合适的文件系统。当文件系统被读入到ramdisk中，内核实际上会挂载ramdisk设备作为根文件系统。最后，内核生成一个内核线程，用以执行initrd镜像中的linuxrc文件。

当linuxrc脚本执行完毕后，内核会卸载initrd，并继续执行系统引导的最后一些步骤。如果真正的根设备中有一个名为/initrd的目录，Linux会将initrd文件系统挂载到这个路径上（称为挂载点）。如果最终的根文件系统中不包含这个目录，initrd镜像就简单地丢弃了。

如果内核命令行中包含root=参数并指向一个ramdisk(比如root=/dev/ram0)，那么前面所描述的initrd的行为会发生两个重要的变化。首先，linuxrc文件将不会拥有一个得到处理。其次，内核不会尝试挂载另外一个文件系统作为其文件系统。这意味着你可以拥有一个Linux系统，其中initrd是它唯一的根文件系统。这对于小型的系统配置很有用，这类系统中唯一的根文件系统就是ramdisk。如果在内核命令行中执行/dev/ram0，当整个系统初始化完成后，initrd就会成为最终的根文件系统。

## initramfs

initramfs和initrd作用类似，但运行机制和技术实现细节差别很大。

initramfs是在调用do_basic_setup()之前加载的，这就提供了一种在加载设备驱动之前加载固件的机制。

从实用的角度看，initramfs更加容易实用。initramfs是一个cpio格式的档案文件，而initrd是一个实用gzip压缩过的文件系统镜像。这个简单的区别让initramfs更易实用，而且无须成为root用户就能创建它。它已经集成到Linux内核源码树中(.../usr目录的内容)了，当构建内核镜像时，会自动创建一个默认小型(几乎没有内容)initramfs镜像。改动这个小型镜像要比构建和加载新的initrd镜像容易的多。

Linux内核源码树的.../scripts目录中有一个名为gen_initramfs_list.sh的脚本文件，其中定义了哪些文件会默认包含在initramfs档案文件中。

### 定制initramfs

有两种针对特定需求定制initramfs的方法。一种方法是创建一个cpio格式的档案文件，其中包含你所需的所有文件，另一种方法是指定一系列目录和文件，这些文件会和gen_initramfs_list.sh所创建的默认文件合并在一起。你可以通过内核配置工具来为initramfs指定一个文件源。

    -> General setup
        -> Initial RAM filesystem and RAM disk (initramfs/initrd) support (BLK_DEV_INITRD [=y])
            -> Initramfs source file(s) (INITRAMFS_SOURCE [=])

INITRAMFS_SOURCE指向开发工作站上的一个目录。

* [1] .../Documentation/filesystems/ramfs-rootfs-initramfs.txt

