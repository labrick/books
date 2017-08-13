# 3.13 BusyBox

2017-02-22

--------------

## 嵌入式Linux的瑞士军刀

BusyBox是高度模块化和高度可配置性的，而且可以对其进行裁剪，工具小巧高效，可以替代一大批常用的标准Linux命令行工具，而且它所需要的整体系统资源很少

实际上BusyBox重新实了桌面Linux发行版中的命令，只是功能有所简化，可以将它看做对应命令的精简版本。在某种情况下，它只支持一部分常用的命令行参数。而且，实际上你会发现，BusyBox所实现的这部分命令功能子集已足以满足一般的嵌入式需求。

## 配置构建BusyBox

1. 执行一个配置工具，并开启所选的特性；
2. 运行make命令构建BusyBox软件包；
3. 将编译出的二进制工具和一系列符号链接(symbolic link)安装到目标系统中。

下载BusyBox源码，和配置linux内核一样，在BusyBox顶层目录下执行`make menuconfig`会启动一个图形化配置工具(基于ncurses图形库)，`make help`会输出所有可用的make目标以及它们的相关信息。

    $ make menuconfig

具体的先省略........

安装时目录结构：

    # make install
    $ ls -l /
    total 12
    drwxrwxr-x  2   root    root    4096    Feb 23  14:33   bin
    lrwxrwxrwx  1   root    root      11    Feb 23  14:33   linuxrc -> bin/busybox
    drwxrwxr-x  2   root    root    4096    Feb 23  14:33   sbin
    drwxrwxr-x  4   root    root    4096    Feb 23  14:33   usr

    $ tree
    .
    |-- bin
    |   |-- addgroup -> busybox
    |   |-- busybox
    |   |-- cat -> busybox
    |   |-- cp -> busybox
    ...
    |   `-- zcat -> busybox
    |   linuxrc -> bin/busybox
    |   sbin
    |   |-- halt -> ../bin/busybox
    |   |-- ifconfig -> ../bin/busybox
    |   |-- init -> ../bin/busybox
    |   |-- klogd -> ../bin/busybox
    ...
    |   `-- syslogd -> busybox
    `-- usr 
        |-- bin
        |   |-- [ -> ../../bin/busybox 
        |   |-- basename -> ../../bin/busybox 
    ...
        |   |-- xargs -> ../../bin/busybox 
        |    `-- yes -> busybox
        `-- bin
            `-- chroot -> busybox

实际上，这些目录中可能包含100多个符号链接，具体数目取决于在配置BusyBox时开启的功能。

## BusyBox的操作

构建BusyBox后，最终会获得一个二进制可执行程序，名称为busybox，我们可使用这个名称本身来执行BusyBox，但一般通过符号链接(symlink)来调用它。

如果在执行BusyBox时没有带任何参数，它会输出所有它支持的功能（命令），这些函数的功能是我们在配置BusyBox时开启的。

想要执行一个特定的函数，可以在命令行中输入busybox，之后加上这个函数的名称。

    $ busybox ls /

注意下BusyBox可执行程序本身，通常都是通过符号链接来直接使用它，比如：

    $ ifconfig eth1 192.168.1.14

这条命令会通过ifconfig符号链接来执行BusyBox应用程序，原理是**BusyBox程序会读取argv[0]的内容，并以此确定用户请求的具体功能。**这里也体现出了argv[0]设计上的巨大作用。

## BusyBox的init

从BusyBox的目录结构可以看出，init为指向busybox的符号链接，也就是BusyBox的init函数接管了内核初始化的最后一步。

BusyBox处理系统初始化的方式不同于标准的System V init（访问/etc/inittab文件），BusyBox也会读取inittab文件，但这个inittab文件采用的语法格式有所不同，但一般情况下并不需要使用inittab文件。

### 最小化基于BusyBox的根文件系统

    $ tree
    .
    |-- bin
    |   |-- busybox
    |   |-- cat -> busybox
    |   |-- dmesg -> busybox
    |   |-- echo -> busybox
    |   |-- hostname -> busybox
    |   |-- ls -> busybox
    |   |-- ps -> busybox
    |   |-- pwd -> busybox
        |   `-- sh -> busybox
        |-- dev
        |   `-- console
        |-- etc
        `-- proc
        4 directories, 10 files

### BusyBox以默认方式启动

    ...
    Looking up port of RPC 100003/2 on 192.168.1.9
    Looking up port of RPC 100005/1 on 192.168.1.9
    VFS: Mounted root (fns filesystem).
    Freeing init memory: 96K
    -----------------------BusyBox产生...................
    Bummer, could not run '/etc/init.d/rcS': No such file or directory

    Please press Enter to activate this console.

    BusyBox v1.01 (2015.12.03-19:09+0000) Built-in shell (ash)
    Enter 'help' for a list of built-in commands.

    -sh: can't access tty; job contrl turned off
    / #
    
可以看到BusyBox第一件事就是去找/etc/init.d/rcS文件（而不是inittab文件），这是BusyBox搜索的默认初始化脚本文件。

当BusyBox完成初始化后，提示用户按回车键激活一个控制台，接着执行一个ash(BusyBox的内置shell)会话，并等待用户输入。

### rcS初始化脚本示例

在BusyBox生成一个交互式shell之前，它会尝试执行一些定义在/etc/init.d/rcS中的命令。

    #!/bin/sh

    echo "Mounting proc"
    mount -t proc /proc /proc

    echo "Starting system loggers"
    syslogd
    klogd

    echo "Configuring loopback interface"
    ifconfig lo 127.0.0.1

    echo "String inetd"
    xinetd

    # start a shell
    busybox sh


