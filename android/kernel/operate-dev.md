# 驱动操作

2017-01-10

-----------------


应用操作驱动的接口只有三种：

1. read函数
2. write函数
3. ioctl函数

当然还有open和close函数；

read/writed都是遵循标准C的语法，ioctl函数呢？

可以想到采用read/write并不能满足所有驱动的需求，还有很多驱动并不是简单的读写就可以解决问题的，那么就需要ioctl来进行解决。

ioctl函数存在的目的是采用命令cmd来确定驱动所采取的操作，驱动程序当中可以采用switch/case来判断命令cmd从而进行不同的行为，如果驱动只是用一次，cmd可以随意，但是linux驱动都是共多应用多设备使用的，所以对cmd的要求就比较高，具体的可见：linux/include/linux/ioctl.h --> arch/arm/include/asm/ioctls.h --> linux/asm-generic/ioctl.h
