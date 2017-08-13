# 3.12.02 伪文件系统proc

2017-02-16

--------------

/proc文件系统的名称来源于它最初的设计目的：接口，内核通过它可以获取一个Linux系统上所有运行进程的信息。

/proc文件系统已经成为几乎所有Linux系统，甚至嵌入式Linux系统的必需品，**很多用户空间的应用程序都依靠/proc文件系统中的内容来完成他们的工作。**

内核中运行的每个用户进程都会由/proc文件系统中的一个对应条目代表，比如init进程，它的进程ID总是被分配为1，而/proc/1目录就代表着这个init进程。

## 系统配置

    -> File systems
        -> Pseudo filesystems
            -> /proc file system support (PROC_FS [=y])


mount <== /proc/mounts
类似的还有top, ps, free, pkill, pmap, uptime
