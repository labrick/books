# 3.11.01 设备驱动模块工具

2017-02-13

-------------

1. insmod

    安装一个设备驱动模块。
    这个应该是最常用的了，但也是最简单的，它不需要也不接受任何的命令行参数，但他需要一个完整的路径名，因为它不包含用于搜索模块的逻辑处理。

2. lsmod

    显示一个格式化的列表，列出加载到内核中的所有模块。本质是仅仅是将/proc/modules的输出信息调整一下格式。

3. modprobe

    modprobe是个巧妙的工具。其可以发现模块之间的依赖关系，并按照合适的顺序自动加载这些依赖。比如：文件系统ext3.ko依赖于文件系统日志函数jbd.ko，所以执行`modprobe ext3`这条命令就会自动加载jbd.ko和ext3.ko两个驱动模块。而`modprobe -r ext3`会将jbd.ko和ext3.ko都删除掉。

    modprobe工具是由配置文件modprobe.conf驱动的。这个可以帮助系统开发人员将设备和设备驱动程序关联起来。modprobe工具在编译时如果没有有效的modprobe.conf文件，它会使用一些默认规则创建一些列默认值。采用`modprobe -c`可以先显示出modprobe所使用的这组默认规则。

    **modprobe.conf可以配置内核启动时发现相应芯片加载对应的驱动程序，而这个功能正在被udev所取代。**

4. depmod

    modprobe是怎样直到一个给定模块所依赖的其他模块的呢？

    这个过程中，depmod工具起到了关键的作用。当modprobe执行时，它会在模块的安装目录中搜索一个名为modules.dep的文件。depmod工具创建了描述模块依赖关系的文件。
    
    这个文件中列出了内核构建系统所配置的所有模块。

    modules.dep中的依赖关系看起来是这样的：

        ext3.ko: jbd.ko
        ...

    通常，depmod都是在内核构建时自动运行的。然而，在一个交叉开发环境中，你必须有一个较差版本的depmod，它知道如何识别哪些针对目标架构以本地模式编译的版本。另外，大多数嵌入式发行版都可以设置init脚本，使系统在每次开启时运行depmod，以保证模块间的依赖关系得到及时更新。

5. rmmod

    rmmod工具也很简单，它是将一个模块从运行中的内核中删除。

        rmmod hello

    **与modprobe不同，rmmod不会删除一个模块所依赖的模块。**如果想删除，可以使用modprobe -r

6. modinfo

    modinfo会以列表的形式呈现出filename/license/description/author/depends/vermagic/parm


