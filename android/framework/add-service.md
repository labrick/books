# 注册服务

2017-01-09

----------------------

在frameworks/base/services/java/com/android/server/SystemServer.java中:

    ServiceManager.addService(Context.POWER_SERVICE, new PowerManagerService());

addService()函数将各个服务注册到Context Manager中。

这个文件中包含了两个类：

ServerThread包含了各种服务的注册信息；
SystemServer则对ServerThread进行了实例化。

    1. init.rc中启动zygote时加上--start-system-server参数启动SystemServer
    2. SystemServer中实例化ServerThread，而在ServerThread中注册启动了各种服务到Context Manager中



----------------------

Context Manager: 一种管理服务的系统进程

markdown不支持注脚，只能先这样了
