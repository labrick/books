# sunxi内核的配置

2017-04-10

-------------------

玩过allwinner soc的应该都知道，sunxi的内核编译是经过上层build.sh调用编译的，这样如果在kernel目录没有.config文件，他就会根据配置自动生成一个，做出这个操作的脚本在../tools/scripts/mkrule文件中：

    <芯片编号>_<系统平台>   <buildroot配置文件> <内核配置文件>
    sun50iw1p1_android      sun50i_defconfig    sun50iw1p1smp_android_defconfig
    sun8iw5p1_android       sun8i_defconfig     sun8iw5p1smp_android_defconfig

具体复制哪里的内核配置文件






Instantiate from user-space 从用户空间来创建i2c设备

直接使用指令来完成：

echo eeprom 0x50 > /sys/bus/i2c/devices/i2c-0/new_device
