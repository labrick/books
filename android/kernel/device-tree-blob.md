# 3.10 设备树对象

2017-02-13

--------------

设备树对象(Device Tree Blob)也被称作扁平设备树、设备树二进制文件，或者简称设备树。

DTB是一个数据库，代表了一个给定板卡上的硬件原件，它是由IBM公司的OpenFirmware规范衍生而来的，并且被选择作为一种默认的机制，用于将底层硬件信息从引导加载程序传递至内核。

设备树对象是由一个特殊的编译器“编译”生成的，生成的二进制文件采用U-boot和Linux能够理解的格式。dtc编译器一般是由嵌入式Linux发行版提供的。

设备树语法可以参考[Power.org制作的文档][3]。

设备树源码(dts)==>设备树对象(dtb)

    dtc -O dtb -o myboard.dtb -b 0 myboard.dts

设备树对象(dtb)==>设备树源码(dts)

    dtc -I dtb -O dts xxx.dtb >xxx.dts

[1]: .../arch/arm/boot/dts
[2]: http://jdl.com/software
[3]: http://www.power.org/resources/downloads/Power_ePAPR_APPROVED_v1.0.pdf
