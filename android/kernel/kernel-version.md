# 内核版本

linux内核版本可以通过下面的方法获取：

1. 内核源码树的顶层目录中包含一个Makefile文件，这个文件的开始几行即说明了版本号。

        VERSION = 3
        PATCHLEVEL = 4
        SUBLEVEL = 39
        EXTRAVERSION =
        NAME = Saber-toothed Squirrel

        KERNELVERSION = $(VERSION)$(if $(PATCHLEVEL),.$(PATCHLEVEL)$(if $(SUBLEVEL),.$(SUBLEVEL)))$(EXTRAVERSION)

    目前KERNELVERSION这个宏逐渐被KERNELRELEASE宏取代，因为这个字符串不仅包含了内核版本号，还包含了一个与源码版本控制工具git有关的标记。

    EXTRAVERSION则是补充自己内核项目的版本号。

2. 在已经启动的内核中执行`cat /proc/version`可以查看。

3. 在可以执行命令行的地方（linux terminal/ adb shell）中执行：

    uname -r
