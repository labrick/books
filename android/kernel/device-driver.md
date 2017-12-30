# 3.11 设备驱动

2017-02-13

----------

设备驱动程序的作用：

1. 将用户程序隔离开来，阻止它们随意访问关键的内核数据结构和硬件设备。
2. 提供一个统一的方法，用于和硬件或内核层设备通信。

## 构建驱动程序的步骤

1. 从顶层Linux源码目录开始，在目录.../drivers/char下创建一个名为examples的目录。
2. 在内核配置种添加一个新的菜单项，由此我们能够构建examples，并可以指定将它构建成内置的或是可加载的内核模块。
3. 修改.../drivers/char/Makefile文件，在其中添加对examples子目录的条件编译，以第(2)步中创建的菜单项的值为条件。
4. 为examples新目录创建一个Makefile，并在其中添加对hello.o模块模块的条件编译，以第(2)步中创建的菜单项的值为条件。
5. 创建驱动程序hello.c源码文件。

## 基本类型

Linux系统将设备分为三种基本类型，每个模块通常实现为其中某一类：字符模块、块模块或者网络模块。

### 字符模块

字符设备是个能够像字节流（类似文件）一样被访问的设备，由字符设备驱动程序来实现这种特性。字符设备驱动程序通常至少实现open、close、read和write系统调用。字符终端(/dev/console)和串口(/dev/ttys0以及类似设备)就是两个字符设备，它们能够很好的说明“流”这种抽象概念。

### 块设备

在大多数Unix系统中，进行I/O操作时块设备每次只能传输一个或多个完整的块，而每块包含512字节（或2的更高次幂字节的数据）。Linux可以让应用程序像字符设备一样的读写块设备，允许一次传递任意多字节的数据。**因而，块设备和字符设备的区别仅仅在于内核内部管理数据的方式，也就是内核及驱动程序之间的接口，而这些不同对用户来讲是透明的。**在内核中，和字符设备驱动程序相比，块驱动程序具有完全不同的接口。

### 网络设备

许多网络连接（尤其是使用TCP协议的连接）是面向流的，但网络设备却围绕数据包的传输和接收而设计。

------------

> 由于不是面向流的设备，因此将网络接口映射到文件系统中的节点（比如/dev/tty1）比较困难。Unix访问网络接口的方法仍然是给它们分配一个唯一的名字（比如eth0），但这个名字在文件系统中不存在对应的节点。内核和网络设备驱动程序间的通信，完全不同于内核和字符以及块驱动程序之间的通信，内核调用一套和数据包传输相关的函数而不是read、write等。


## 最小设备驱动程序示例

    /* 最小设备驱动程序示例 */
    #include <linux/module.h>

    static int __init hello_init(void)
    {
        printk(KERN_INFO "Hello Example Init\n");

        return 0;
    }

    static void __init hello_exit(void)
    {
        printk("Hello Example Exit\n");
    }

    module_init(hello_init);
    module_exit(hello_exit);

    MODULE_AUTHOR("BRICK");
    MODULE_DESCRIPTION("Hello World Example");
    MODULE_LICENSE("GPL");

## 加载模块

    modprobe hello      // 加载设备驱动程序，必需是root用户
    modprobe -r hello      // 卸载设备驱动程序，必需是root用户

## 模块参数

很多设备驱动程序模块都可以接受参数，改变其行为【这个我还真不知道呢....】。这样的例子包括开启调试模式、设置详细输出模式以及指定与具体模块相关的选项。

看个例子：

    /* 最小设备驱动程序示例 */
    #include <linux/module.h>

    static int debug_enable = 0;        /* 添加的驱动参数 */
    module_param(debug_enable, int, 0); /* 添加这两行 */
    MODULE_PARM_DESC(debug_enable, "Enable module debug mode.");

    static int __init hello_init(void)
    {
        /* 现在打印新的模块参数的值 */
        printk("Hello Example Init - debug mode is %s\n",
            debug_enable ? "enabled" : "disabled");

        return 0;
    }

    static void __init hello_exit(void)
    {
        printk("Hello Example Exit\n");
    }

    module_init(hello_init);
    module_exit(hello_exit);

    MODULE_AUTHOR("BRICK");
    MODULE_DESCRIPTION("Hello World Example");
    MODULE_LICENSE("GPL");
    
module_param是一个宏，在文件.../include/linux/moduleparam.h中（modules.h包含了这个文件）定义。它向内核模块子系统注册了这个模块参数。
MODULE_PARM_DESC也是一样，它向内核模块子系统注册了一个和参数相关的字符串描述。
可以通过modinfo命令显示。

    # insmod hello.ko debug_enable=1
    Hello Example Init - debug mode is enabled
    # insmod hello.ko
    Hello Example Init - debug mode is disabled

* [1] 如果没有在控制台中看到一些关注的信息，可以尝试关闭系统中的syslogd或是降低控制台的日志级别(loglevel)
