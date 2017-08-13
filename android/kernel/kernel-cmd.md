# 内核命令行

2017-01-12

-------------------

引导加载程序引导到内核后会将控制权交给内核，同时会传递一些参数给内核，这个参数即为内核命令行。

**是上面这样的吗？**

比如Linux启动时的一句log信息：

    Kernel command line: console=ttyS0,115200 root=/dev/nfs ip=dhcp

.../init/main.c中调用的setup_arch()所接收的参数即为指向这个内核命令行的指针。

    setup_arch(&command_line);

.../Document子目录下的kernel-parameters.txt文件中记录所有的内核命令行参数(由于未能及时更新可能不够全面)

## \__setup宏

\__setup是定义在.../include/linux/init.h中的一个特殊的宏，它用于将内核命令行字符串的一部分同某个函数关联起来，而这个函数会处理字符串的那个部分。

    /*
     * Only for really core code.  See moduleparam.h for the normal way.
     *
     * Force the alignment so the compiler doesn't space elements of the
     * obs_kernel_param "array" too far apart in .init.setup.
     */
    #define __setup_param(str, unique_id, fn, early)            \
        static const char __setup_str_##unique_id[] __initconst \
            __aligned(1) = str; \
        static struct obs_kernel_param __setup_##unique_id  \
            __used __section(.init.setup)           \
            __attribute__((aligned((sizeof(long)))))    \
            = { __setup_str_##unique_id, fn, early }
        
    #define __setup(str, fn)                    \
        __setup_param(str, fn, fn, 0)

这里以指定控制台设备为例进行说明：

指定控制台设备的初始化工作是printk.c中的console_setup()函数完成的。

    /*
     * Set up a list of consoles.  Called from init/main.c
     */
    static int __init console_setup(char *str)
    {
       char buf[sizeof(console_cmdline[0].name) + 4]; /* 4 for index */
       char *s, *options, *brl_options = NULL;
       int idx;
       ...
       return 1;
    }
    __setup("console=", console_setup);

你可以将\__setup宏看做一个注册函数，即为内核命令行中控制台相关参数注册的处理函数。实际上是指，当在内核命令行中碰到console=字符串时，就调用\__setup宏的第二个参数所指定的函数，这里就是调用函数console_setup()。

这里的原理比较复杂，后续需要认真研究下
