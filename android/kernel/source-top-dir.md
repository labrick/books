# 源码顶层目录

2017-01-10

------------------

源码目录结构如下：

| 目录名称                      | 简介 
| :-----------------            | :--------- 
| arch/arm/kernel/              | 与具体架构相关的内核代码
| arch/arm/kernel/head.*        | 内核中与具体架构相关的启动代码 
| arch/arm/kernel/init_task.c   | 内核中所需的初始的线程和任何结构体
| arch/arm/mm/                  | 与具体架构相关内存管理代码
| arch/arm/common/              | 与具体架构相关的通用代码，因架构而异
| arch/arm/mach-ixp4xx/         | 与具体**机器**相关的代码，主要用于初始化
| arch/arm/nwfpe/               | 与具体架构相关的浮点运算模拟(floating-point emulation)代码
| arch/arm/lib.a                | 与具体架构相关的通用程序库，因架构而异
| init                          | 主要的内核初始化代码
| usr                           | 内置的initramfs镜像
| kernel                        | 内核自身的通用部分
| mm                            | 内存管理代码的通用部分
| fs                            | 文件系统代码
| ipc                           | 进程间通信，比如SysV IPC
| security                      | Linux安全组件
| crypto                        | 加密API
| block                         | 内核块设备层的核心代码
| lib                           | 通用的程序库函数
| lib/lib.a                     | 通用的内核辅助函数
| drivers                       | 所有的内置驱动，不包含可加载的模块
| sound                         | 声音驱动
| firmware                      | 驱动固件对象
| net                           | Linux网络
| .tmp_kallsyms2.o              | 内核符号表
| Documentation
| include
| Makefile
| samples
| scripts
| tools
| virt
| README
| MAINTAINERS
| Kconfig
| Kbuild
| CREDITS
| COPYING
