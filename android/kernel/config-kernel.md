# 内核配置

2017-01-11

-----------------

linux是一个精密而复杂的系统，具有太多的功能模块，他们之间的有效的关联与解耦是个关键，linux采用.config来配置最终镜像所包含的功能模块。

而对.config的编辑是个复杂的工作，从最开始的命令行方式配置(make config)发展到现在的最常用的菜单配置(make menuconfig)，当然还有很多其他的配置方式，具体的可以参见`make help`。

## 对.config的处理

大多数软件构建过程中，构建系统会处理这个.config文件，并生成一个名为autoconf.h(**这里才是.config的本质**)的C语言文件，放在目录include/generated/中，这个文件是自动生成的。很多内核源文件直接使用预处理指令`#include`来包含这个文件。


多加注意下面这个指令：

    make ARCH=arm help

在这里会列出对于某个SOC系列的默认配置文件，如果不知道采用那个默认配置文件时，可以到这里查找一下。

比如：

    sun8iw1p1smp_defconfig   - Build for sun8iw1p1smp
    sun8iw3p1smp_android_defconfig - Build for sun8iw3p1smp_android
    sun8iw3p1smp_defconfig   - Build for sun8iw3p1smp
    sun8iw3p1smp_min_defconfig - Build for sun8iw3p1smp_min
    sun8iw5p1smp_android_defconfig - Build for sun8iw5p1smp_android
    sun8iw5p1smp_defconfig   - Build for sun8iw5p1smp
    sun8iw5p1smp_min_defconfig - Build for sun8iw5p1smp_min
    sun8iw5p1smp_tina_defconfig - Build for sun8iw5p1smp_tina
    sun8iw6p1smp_defconfig   - Build for sun8iw6p1smp
    sun8iw6p1smp_min_defconfig - Build for sun8iw6p1smp_min
    sun8iw7p1smp_defconfig   - Build for sun8iw7p1smp
    sun8iw8p1smp_defconfig   - Build for sun8iw8p1smp
    sun8iw9p1smp_defconfig   - Build for sun8iw9p1smp

产生的文件：

    Architecture specific targets (arm):
    * zImage        - Compressed kernel image (arch/arm/boot/zImage)
      Image         - Uncompressed kernel image (arch/arm/boot/Image)
    * xipImage      - XIP kernel image, if configured (arch/arm/boot/xipImage)
      uImage        - U-Boot wrapped zImage
      bootpImage    - Combined zImage and initial RAM disk
                      (supply initrd image via make variable INITRD=<path>)
      dtbs          - Build device tree blobs for enabled boards
      install       - Install uncompressed kernel
      zinstall      - Install compressed kernel
      uinstall      - Install U-Boot wrapped compressed kernel
                      Install using (your) ~/bin/installkernel or
                      (distribution) /sbin/installkernel or
                      install to $(INSTALL_PATH) and run lilo

make的选项含义：

    make V=0|1 [targets] 0 => quiet build (default), 1 => verbose build
    make V=2   [targets] 2 => give reason for rebuild of target
    make O=dir [targets] Locate all output files in "dir", including .config
    make C=1   [targets] Check all c source with $CHECK (sparse by default)
    make C=2   [targets] Force check of all c source with $CHECK
    make RECORDMCOUNT_WARN=1 [targets] Warn about ignored mcount sections
    make W=n   [targets] Enable extra gcc checks, n=1,2,3 where
                1: warnings which may be relevant and do not occur too often
                2: warnings which occur quite often but may still be relevant
                3: more obscure warnings, can most likely be ignored
                Multiple levels can be combined with W=12 or W=123

## Kconfig

scripts/kconfig/Makefile负责对Kconfig分析处理：

    menuconfig: $(obj)/mconf
         $< $(Kconfig)


## 将编译信息输出到文件中

    make 2>&1 | tee build.out
